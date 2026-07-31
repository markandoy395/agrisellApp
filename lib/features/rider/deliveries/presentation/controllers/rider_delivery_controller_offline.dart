part of 'rider_delivery_controller.dart';

extension RiderDeliveryControllerOffline on RiderDeliveryController {
  void setBackendReachable(bool reachable) {
    if (_isBackendReachable == reachable) return;
    _isBackendReachable = reachable;
    _syncEngine.setBackendReachable(reachable);
    _notify();
    if (reachable) unawaited(synchronizeOfflineActions());
  }

  Future<void> synchronizeOfflineActions() async {
    final riderId = _riderId;
    if (riderId == null || riderId.isEmpty || !_isBackendReachable) return;
    await _ensureOfflineQueue(riderId);
    await _syncEngine.synchronize();
    _lastSynchronizationTime = _syncEngine.lastSynchronizedAt;
    if (_offlineQueue.pendingCount == 0 && _offlineQueue.attentionCount == 0) {
      try {
        await refreshActiveDelivery();
      } on Exception {
        // The local active delivery remains available until reconciliation.
      }
    }
    await _clearResolvedProblemDrafts();
    await _persistState();
  }

  Future<bool> retryOfflineAction(String localId) => _syncEngine.retry(localId);

  Future<void> retryFailedOfflineActions() async {
    for (final action in _offlineQueue.actions) {
      if (action.status == OfflineDeliveryActionStatus.failed) {
        await _offlineQueue.retry(action.localId);
      }
    }
    await synchronizeOfflineActions();
  }

  Future<void> _ensureOfflineQueue(String riderId) async {
    if (_offlineQueueInitialized) return;
    await _offlineQueue.initialize(riderId);
    _offlineQueueInitialized = true;
    _pendingOfflineActionCount = _offlineQueue.pendingCount;
  }

  Future<DeliveryActionResult> _queueStatusUpdate(
    DeliveryStatusUpdateCommand command,
  ) async {
    await _ensureOfflineQueue(command.riderId);
    final action = await _offlineQueue.add(
      riderId: command.riderId,
      deliveryId: command.deliveryId,
      type: OfflineDeliveryActionType.deliveryStatusUpdate,
      payload: encodeStatusCommand(command),
      originalTimestamp: command.location?.timestamp ?? DateTime.now(),
      idempotencyKey: command.idempotencyKey,
    );
    final request = _request(command.deliveryId);
    if (request == null) return await _missingDelivery();
    final events = <DeliveryStatusEvent>[
      ..._activeDeliveries.eventsFor(command.deliveryId),
      DeliveryStatusEvent(
        eventId: action.localId,
        deliveryId: command.deliveryId,
        previousStatus: command.previousStatus,
        newStatus: command.newStatus,
        riderId: command.riderId,
        timestamp: action.originalTimestamp,
        latitude: command.location?.latitude,
        longitude: command.location?.longitude,
        accuracyMeters: command.location?.accuracyMeters,
        locationTimestamp: command.location?.timestamp,
        isManualArrivalOverride: command.manualArrivalOverride,
        note: command.note,
        reasonCode: command.reasonCode,
        proofReference: command.proofReference,
        source: DeliveryEventSource.offline,
        syncStatus: DeliveryEventSyncStatus.pending,
      ),
    ];
    final updated = request.copyWith(
      stage: legacyStageForDeliveryStatus(command.newStatus),
    );
    _activeDeliveries.update(
      DeliveryStatusSnapshot(
        request: updated,
        currentStatus: command.newStatus,
        events: events,
      ),
    );
    await _replace(updated, riderId: command.riderId);
    return DeliveryActionResult.success(updated);
  }

  Future<DeliveryActionResult> _queuePickupProof(
    PickupCompletionCommand command,
  ) async {
    await _ensureOfflineQueue(command.riderId);
    final existing = _offlineQueue.firstOpenFor(
      deliveryId: command.deliveryId,
      type: OfflineDeliveryActionType.pickupProof,
    );
    if (existing != null) {
      return const DeliveryActionResult.failure(
        failure: DeliveryActionFailure.offline,
        message: 'Pickup proof is already waiting to synchronize.',
      );
    }
    await _offlineQueue.add(
      riderId: command.riderId,
      deliveryId: command.deliveryId,
      type: OfflineDeliveryActionType.pickupProof,
      payload: encodePickupCommand(command),
      originalTimestamp: command.location.timestamp ?? DateTime.now(),
      idempotencyKey: command.idempotencyKey,
    );
    await _persistState();
    return const DeliveryActionResult.failure(
      failure: DeliveryActionFailure.offline,
      message: 'Pickup proof is saved and waiting to synchronize.',
    );
  }

  Future<DeliveryActionResult> _queueDeliveryProof(
    DeliveryCompletionCommand command,
  ) async {
    await _ensureOfflineQueue(command.riderId);
    final existing = _offlineQueue.firstOpenFor(
      deliveryId: command.deliveryId,
      type: OfflineDeliveryActionType.deliveryProof,
    );
    if (existing != null) {
      return const DeliveryActionResult.failure(
        failure: DeliveryActionFailure.offline,
        message: 'Delivery proof is already waiting to synchronize.',
      );
    }
    await _offlineQueue.add(
      riderId: command.riderId,
      deliveryId: command.deliveryId,
      type: OfflineDeliveryActionType.deliveryProof,
      payload: encodeDeliveryCommand(command),
      originalTimestamp: command.finalLocation.timestamp ?? DateTime.now(),
      idempotencyKey: command.idempotencyKey,
    );
    await _persistState();
    return const DeliveryActionResult.failure(
      failure: DeliveryActionFailure.offline,
      message: 'Delivery proof is saved and waiting to synchronize.',
    );
  }

  Future<void> _queueProblemReport({
    required String riderId,
    required String deliveryId,
    required String idempotencyKey,
    required Map<String, Object?> payload,
    required DateTime reportedAt,
  }) async {
    await _ensureOfflineQueue(riderId);
    await _offlineQueue.add(
      riderId: riderId,
      deliveryId: deliveryId,
      type: OfflineDeliveryActionType.problemReport,
      payload: payload,
      originalTimestamp: reportedAt,
      idempotencyKey: idempotencyKey,
    );
    await saveRecoveryData('draftReport:$deliveryId', payload);
  }

  void _offlineQueueChanged() {
    _pendingOfflineActionCount = _offlineQueue.pendingCount;
    _notify();
    if (_riderId == null || _isRestoring) return;
    unawaited(_persistState());
  }

  void _offlineSyncChanged() {
    _lastSynchronizationTime = _syncEngine.lastSynchronizedAt;
    _notify();
  }
}
