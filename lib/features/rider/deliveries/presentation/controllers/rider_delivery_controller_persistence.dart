part of 'rider_delivery_controller.dart';

extension RiderDeliveryControllerPersistence on RiderDeliveryController {
  Future<void> applyAuthoritativeAvailability(
    RiderAvailability availability, {
    bool loadRequests = true,
  }) async {
    var resolved = availability;
    if (hasActiveDelivery && !availability.isHandlingDelivery) {
      final active = _requests.firstWhere(
        (request) =>
            request.isAssignedTo(_riderId ?? '') && !request.stage.isTerminal,
      );
      resolved = riderAvailabilityForDeliveryStage(
        active.stage,
        _status.availability,
      );
    }
    _status = _status.copyWith(availability: resolved);
    if (!resolved.canReceiveRequests && !resolved.isHandlingDelivery) {
      _requests = removeReadyPickupRequests(_requests);
      _loadState = RiderRequestLoadState.offline;
    }
    _notify();
    await _persistState();
    final riderId = _riderId;
    if (loadRequests && riderId != null && resolved.isOnline) {
      await load(riderId: riderId);
    }
  }

  Future<bool> restore({required String riderId}) async {
    _riderId = riderId;
    if (riderId.isNotEmpty) {
      _isRestoring = true;
      try {
        await _ensureOfflineQueue(riderId);
      } on Exception {
        // A damaged queue must not prevent the active delivery from restoring.
      } finally {
        _isRestoring = false;
      }
    }
    final store = _stateStore;
    if (store == null || riderId.isEmpty) return false;
    RiderDeliveryStateSnapshot? snapshot;
    try {
      snapshot = await store.load(riderId);
    } on Exception {
      return false;
    }
    if (snapshot == null) return false;
    final availability =
        _status.verificationStatus == RiderVerificationStatus.verified
        ? snapshot.availability
        : RiderAvailability.offline;
    _status = _status.copyWith(availability: availability);
    _pendingOfflineActionCount = _offlineQueueInitialized
        ? _offlineQueue.pendingCount
        : snapshot.pendingOfflineActionCount;
    _lastSynchronizationTime = snapshot.lastSynchronizationTime;
    _recoveryData = Map.unmodifiable(snapshot.recoveryData);
    _activeDeliveries.clear();
    final storedActive = [...snapshot.activeDeliveries];
    final summary = snapshot.activeDeliverySummary;
    final deliveryStatus = snapshot.currentDeliveryStatus;
    if (storedActive.isEmpty && summary != null && deliveryStatus != null) {
      storedActive.add(
        RiderActiveDeliverySnapshot(
          recordId:
              snapshot.activeDeliveryId ?? 'restored-${summary.deliveryId}',
          acceptedAt:
              snapshot.statusEvents.firstOrNull?.timestamp ?? DateTime.now(),
          summary: summary,
          status: deliveryStatus,
          events: snapshot.statusEvents,
        ),
      );
    }
    _requests = [
      for (final item in storedActive)
        item.summary.toLegacyRequest(riderId: riderId, status: item.status),
    ];
    for (final item in storedActive) {
      _activeDeliveries.restore(
        record: item.toRecord(riderId),
        status: item.status,
        events: item.events,
      );
    }
    _loadState = availability == RiderAvailability.offline
        ? RiderRequestLoadState.offline
        : RiderRequestLoadState.ready;
    _notify();
    return true;
  }

  Future<void> refreshActiveDelivery() async {
    final riderId = _riderId;
    if (riderId == null) return;
    final snapshots = await _repository.fetchActiveDeliveryStatuses(riderId);
    final serverIds = snapshots.map((item) => item.request.id).toSet();
    final pendingIds = _offlineQueue.actions
        .where((item) => item.status == OfflineDeliveryActionStatus.pending)
        .map((item) => item.deliveryId)
        .toSet();
    for (final request in activeDeliveryRequests) {
      if (!serverIds.contains(request.id) && !pendingIds.contains(request.id)) {
        _activeDeliveries.remove(request.id);
      }
    }
    _requests = _requests
        .where(
          (item) =>
              item.stage.isTerminal ||
              serverIds.contains(item.id) ||
              pendingIds.contains(item.id),
        )
        .toList(growable: false);
    for (final item in snapshots) {
      _activeDeliveries.update(item);
      final found = _requests.any((request) => request.id == item.request.id);
      _requests = [
        for (final request in _requests)
          if (request.id == item.request.id) item.request else request,
        if (!found) item.request,
      ];
    }
    _lastSynchronizationTime = DateTime.now();
    _notify();
    await _persistState();
  }

  Future<void> _persistState() async {
    final store = _stateStore;
    final riderId = _riderId;
    if (store == null || riderId == null || riderId.isEmpty) return;
    final active = activeDeliveryRequests;
    final primary = active.firstOrNull;
    final records = {
      for (final record in _activeDeliveries.records) record.requestId: record,
    };
    final activeSnapshots = [
      for (final request in active)
        RiderActiveDeliverySnapshot(
          recordId: records[request.id]?.id ?? 'restored-${request.id}',
          acceptedAt:
              records[request.id]?.acceptedAt ??
              statusEventsFor(request.id).firstOrNull?.timestamp ??
              DateTime.now(),
          summary: ActiveDeliverySummary.fromRequest(request),
          status: statusFor(request),
          events: statusEventsFor(request.id),
        ),
    ];
    try {
      await store.save(
        riderId,
        RiderDeliveryStateSnapshot(
          availability: _status.availability,
          activeDeliveryId: records[primary?.id]?.id ?? primary?.id,
          currentDeliveryStatus: primary == null ? null : statusFor(primary),
          activeDeliverySummary: primary == null
              ? null
              : ActiveDeliverySummary.fromRequest(primary),
          statusEvents: primary == null
              ? const []
              : statusEventsFor(primary.id),
          activeDeliveries: activeSnapshots,
          pendingOfflineActionCount: _pendingOfflineActionCount,
          lastSynchronizationTime: _lastSynchronizationTime,
          lastSynchronizationState: _syncEngine.state.name,
          recoveryData: _recoveryData,
        ),
      );
    } on Exception {
      // Local persistence must never block an otherwise valid rider action.
    }
  }
}
