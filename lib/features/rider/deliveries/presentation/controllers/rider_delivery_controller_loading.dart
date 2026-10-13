part of 'rider_delivery_controller.dart';

extension RiderDeliveryControllerLoading on RiderDeliveryController {
  Future<void> load({
    required String riderId,
    RiderDeliverySearch? search,
  }) async {
    _riderId = riderId;
    _watchRequestChanges(riderId);
    _search = search ?? _search;
    final canLoadActive = _status.availability.isHandlingDelivery;
    final canLoadNearby = canPreviewAdditionalDelivery;
    if (!canLoadNearby && !canLoadActive) {
      _requests = removeReadyPickupRequests(_requests);
      _loadState = RiderRequestLoadState.offline;
      _errorMessage = null;
      _notify();
      await _persistState();
      return;
    }
    _loadState = RiderRequestLoadState.loading;
    _errorMessage = null;
    _notify();
    final generation = ++_requestGeneration;
    _activeRequestLoads++;
    try {
      final page = canLoadNearby
          ? await _repository.fetchNearbyRequests(_buildQuery())
          : null;
      // Assigned deliveries travel beside (not inside) the nearby page so the
      // controller can reconcile both sets without a second backend query.
      final assigned = page?.assignedItems ?? const <DeliveryRequest>[];
      final fetched = page == null
          ? removeReadyPickupRequests(
              await _repository.fetchRequests(
                riderId: riderId,
                search: _search,
              ),
            )
          : <DeliveryRequest>[...page.items, ...assigned];
      if (generation != _requestGeneration) return;
      _requests = _mergeFetchedRequests(fetched, riderId);
      _nextCursor = page?.nextCursor;
      _lastSynchronizationTime = DateTime.now();
      _loadState = RiderRequestLoadState.ready;
    } on Exception catch (error) {
      if (generation != _requestGeneration) return;
      _loadState = RiderRequestLoadState.error;
      _errorMessage = _requestLoadErrorMessage(error);
    } finally {
      _activeRequestLoads--;
      _schedulePendingRealtimeRefresh();
    }
    _notify();
    await _persistState();
  }

  void _schedulePendingRealtimeRefresh() {
    if (_activeRequestLoads != 0 || !_realtimeRefreshPending || _isDisposed) {
      return;
    }
    _realtimeRefreshPending = false;
    final riderId = _riderId;
    if (riderId == null) return;
    _realtimeDebounce?.cancel();
    _realtimeDebounce = Timer(Duration.zero, () {
      if (_isDisposed ||
          (!canReceiveAdditionalDelivery &&
              !_status.availability.isHandlingDelivery)) {
        return;
      }
      unawaited(load(riderId: riderId));
    });
  }

  Future<void> updateNearbySearch(RiderDeliverySearch search) async {
    final previousSearch = _search;
    if (previousSearch != null && !search.hasMovedBeyond(previousSearch)) {
      return;
    }
    _search = search;
    final riderId = _riderId;
    if (riderId != null && canPreviewAdditionalDelivery) {
      await load(riderId: riderId);
      return;
    }
    _notify();
  }

  List<DeliveryRequest> _mergeFetchedRequests(
    Iterable<DeliveryRequest> fetched,
    String riderId,
  ) {
    final retained = _requests.where(
      (request) => request.isAssignedTo(riderId) && !request.stage.isTerminal,
    );
    final visible = canPreviewAdditionalDelivery
        ? fetched
        : removeReadyPickupRequests(fetched);
    final byId = <String, DeliveryRequest>{
      for (final request in retained) request.id: request,
      for (final request in visible) request.id: request,
    };
    return sortRiderRequests(
      byId.values.toList(),
      _requestSort,
      pickupDistanceKm: _matchingContextOrNull()?.pickupDistanceKm,
    );
  }
}

String _requestLoadErrorMessage(Exception error) {
  if (error is DeliveryDataException) {
    if (kDebugMode) {
      debugPrint('[rider.requests] load failed (${error.diagnosticCode})');
    }
    return switch (error.type) {
      DeliveryDataFailureType.authentication =>
        'Please sign in again to load delivery requests.',
      DeliveryDataFailureType.authorization =>
        'Your rider account cannot access delivery requests. '
            'Please sign in again or contact support.',
      DeliveryDataFailureType.offline =>
        'No network connection is available. Reconnect and retry.',
      DeliveryDataFailureType.timeout =>
        'Loading delivery requests timed out. Please retry.',
      _ =>
        'Delivery requests could not be loaded. Please retry or contact support.',
    };
  }
  if (kDebugMode) {
    debugPrint('[rider.requests] load failed (${error.runtimeType})');
  }
  return error is FormatException
      ? 'Some delivery request details could not be read. Please contact support.'
      : 'Delivery requests could not be loaded.';
}
