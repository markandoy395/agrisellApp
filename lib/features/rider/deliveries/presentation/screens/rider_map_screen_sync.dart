part of 'rider_map_screen.dart';

extension _RiderMapScreenSync on _RiderMapScreenState {
  void _startTracking() => unawaited(_locationController.startTracking());

  void _syncConnectivity() {
    final availability = widget.availabilityController;
    _routeController.setConnectivity(
      availability == null ||
          availability.internetStatus == RiderInternetStatus.online,
    );
    _syncNavigation();
  }

  void _syncNavigation() {
    if (widget.isActive) {
      _startTracking();
    } else if (!_locationController.isLiveSharing) {
      unawaited(_locationController.stopTracking());
    }
    final location = _locationController.location;
    if (location == null) return;
    unawaited(
      _routeController.synchronize(
        location: location,
        requests: widget.deliveryController.routeOrderedRequests,
        navigationActive: widget.isActive,
      ),
    );
  }

  void _syncNearbySearch() {
    if (!widget.isActive) return;
    final location = _locationController.location;
    if (location == null) return;
    final search = RiderDeliverySearch(
      latitude: location.latitude,
      longitude: location.longitude,
    );
    final previous = _lastNearbySearch;
    if (previous != null && !search.hasMovedBeyond(previous)) return;
    _lastNearbySearch = search;
    unawaited(widget.deliveryController.updateNearbySearch(search));
  }
}
