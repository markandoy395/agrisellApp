part of 'rider_route_controller.dart';

extension RiderRouteControllerActions on RiderRouteController {
  Future<void> restore() async {
    final generation = _latestGeneration;
    final cached = await _cache.load();
    if (_isDisposed || generation != _latestGeneration || cached == null)
      return;
    _routes = cached.routes;
    _selectedIndex = cached.selectedIndex;
    _selectedRequestId = activeRoute?.requestId;
    _state = RiderRouteState.stale;
    _routeUpdatedAt = activeRoute?.calculatedAt;
    _notify();
  }

  void clear() {
    _latestGeneration++;
    _pendingRequest = null;
    _routes = const [];
    _selectedIndex = 0;
    _selectedRequestId = null;
    _lastRequestOrigin = null;
    _lastDestinationKey = null;
    _lastLocation = null;
    _routeUpdatedAt = null;
    _state = RiderRouteState.idle;
    _errorMessage = null;
    _mapDestination = null;
    _mapDestinationId = null;
    _mapDestinationLabel = null;
    unawaited(_cache.clear());
    _notify();
  }

  Future<void> selectRequest({
    required String requestId,
    required RiderDeviceLocation location,
    required List<DeliveryRequest> requests,
  }) async {
    _mapDestination = null;
    _mapDestinationId = null;
    _mapDestinationLabel = null;
    _selectedRequestId = requestId;
    await synchronize(
      location: location,
      requests: requests,
      navigationActive: true,
    );
  }

  Future<void> selectMapDestination({
    required String destinationId,
    required String destinationLabel,
    required DeliveryRoutePoint destination,
    required RiderDeviceLocation location,
    required List<DeliveryRequest> requests,
  }) async {
    _selectedRequestId = null;
    _mapDestinationId = destinationId;
    _mapDestinationLabel = destinationLabel;
    _mapDestination = destination;
    await synchronize(
      location: location,
      requests: requests,
      navigationActive: true,
    );
  }

  Future<void> refreshRoute({
    required RiderDeviceLocation location,
    required List<DeliveryRequest> requests,
    bool includeAlternatives = false,
  }) => _refreshRoute(
    location: location,
    requests: requests,
    includeAlternatives: includeAlternatives,
  );

  void selectRoute(int index) {
    if (index < 0 || index >= _routes.length || index == _selectedIndex) return;
    _selectedIndex = index;
    _state = RiderRouteState.ready;
    _notify();
    unawaited(_saveRoutes());
  }

  DeliveryRoutePoint displayPoint(RiderDeviceLocation location) {
    final raw = DeliveryRoutePoint(
      latitude: location.latitude,
      longitude: location.longitude,
    );
    final route = activeRoute;
    if (route == null || route.points.length < 2) return raw;
    final snapped = nearestPointOnRoute(raw, route.points);
    return routePointDistanceMeters(raw, snapped) <=
            RiderRouteController._snapThresholdMeters
        ? snapped
        : raw;
  }
}
