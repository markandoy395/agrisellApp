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
    try {
      final page = canLoadNearby
          ? await _repository.fetchNearbyRequests(_buildQuery())
          : null;
      final assigned = page != null && page.items.isEmpty
          ? (await _repository.fetchRequests(
              riderId: riderId,
              search: _search,
            )).where(
              (request) =>
                  request.isAssignedTo(riderId) && !request.stage.isTerminal,
            )
          : const <DeliveryRequest>[];
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
    } on Exception {
      if (generation != _requestGeneration) return;
      _loadState = RiderRequestLoadState.error;
      _errorMessage = 'Delivery requests could not be loaded.';
    }
    _notify();
    await _persistState();
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
