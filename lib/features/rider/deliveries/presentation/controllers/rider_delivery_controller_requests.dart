part of 'rider_delivery_controller.dart';

extension RiderDeliveryControllerRequests on RiderDeliveryController {
  RiderRequestAccessState get requestAccessState => _requestAccess;
  RiderRequestSort get requestSort => _requestSort;
  RiderRequestFilters get requestFilters => _requestFilters;
  String get searchText => _searchText;
  bool get isLoadingMore => _isLoadingMore;
  bool get isRefreshing => _isRefreshing;
  bool get hasMoreRequests => _nextCursor != null;

  void updateRequestEnvironment({
    required RiderRequestAccessState state,
    RiderDeliverySearch? location,
    double? accuracyMeters,
  }) {
    final previous = _requestAccess;
    final previousLocation = _search;
    _requestAccess = state;
    _search = location;
    _requestAccuracyMeters = accuracyMeters;
    if (!state.canPreviewRequests) {
      _requests = removeReadyPickupRequests(_requests);
      _loadState = RiderRequestLoadState.offline;
      _nextCursor = null;
    }
    _notify();
    final riderId = _riderId;
    final moved =
        location != null &&
        (previousLocation == null || location.hasMovedBeyond(previousLocation));
    if (state.canPreviewRequests &&
        (previous != state || moved) &&
        riderId != null) {
      unawaited(load(riderId: riderId));
    }
  }

  void setRequestSort(RiderRequestSort value) {
    if (_requestSort == value) return;
    _requestSort = value;
    _reloadForPresentationChange();
  }

  void applyRequestFilters(RiderRequestFilters value) {
    _requestFilters = value;
    _reloadForPresentationChange();
  }

  void resetRequestFilters() =>
      applyRequestFilters(const RiderRequestFilters());

  void setSearchText(String value) {
    final normalized = value.trim();
    if (_searchText == normalized) return;
    _searchText = normalized;
    _searchDebounce?.cancel();
    _notify();
    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      _reloadForPresentationChange,
    );
  }

  Future<void> refreshRequests() async {
    final riderId = _riderId;
    if (riderId == null) return;
    _isRefreshing = true;
    _notify();
    await load(riderId: riderId);
    _isRefreshing = false;
    _notify();
  }

  Future<void> loadMoreRequests() async {
    final cursor = _nextCursor;
    if (cursor == null ||
        _isLoadingMore ||
        !_requestAccess.canPreviewRequests) {
      return;
    }
    _isLoadingMore = true;
    _notify();
    final generation = _requestGeneration;
    try {
      final page = await _repository.fetchNearbyRequests(
        _buildQuery(cursor: cursor),
      );
      if (generation != _requestGeneration) return;
      final byId = <String, DeliveryRequest>{
        for (final request in _requests) request.id: request,
        for (final request in page.items) request.id: request,
      };
      _requests = sortRiderRequests(
        byId.values.toList(),
        _requestSort,
        pickupDistanceKm: _matchingContext().pickupDistanceKm,
      );
      _nextCursor = page.nextCursor;
    } on Exception {
      _errorMessage = 'More delivery requests could not be loaded.';
    } finally {
      _isLoadingMore = false;
      _notify();
    }
  }

  void _reloadForPresentationChange() {
    _nextCursor = null;
    final riderId = _riderId;
    if (riderId != null && _requestAccess.canPreviewRequests) {
      unawaited(load(riderId: riderId));
    }
  }

  void _watchRequestChanges(String riderId) {
    if (_watchedRiderId == riderId) return;
    _watchedRiderId = riderId;
    unawaited(_requestUpdates?.cancel());
    _requestUpdates = _repository.watchRequestChanges(riderId: riderId).listen((
      _,
    ) {
      _realtimeDebounce?.cancel();
      _realtimeDebounce = Timer(const Duration(milliseconds: 250), () {
        if (canReceiveAdditionalDelivery ||
            _status.availability.isHandlingDelivery) {
          unawaited(load(riderId: riderId));
        }
      });
    });
  }
}
