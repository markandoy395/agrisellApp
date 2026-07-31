part of 'rider_route_controller.dart';

extension RiderRouteControllerActions on RiderRouteController {
  void clear() {
    _latestGeneration++;
    _pendingRequest = null;
    _routes = const [];
    _selectedIndex = 0;
    _selectedRequestId = null;
    _lastRequestOrigin = null;
    _lastLocation = null;
    _routeUpdatedAt = null;
    _state = RiderRouteState.idle;
    _errorMessage = null;
    unawaited(_cache.clear());
    _notify();
  }

  Future<void> selectRequest({
    required String requestId,
    required RiderDeviceLocation location,
    required List<DeliveryRequest> requests,
  }) async {
    _selectedRequestId = requestId;
    await synchronize(
      location: location,
      requests: requests,
      navigationActive: true,
    );
  }

  Future<void> refreshRoute({
    required RiderDeviceLocation location,
    required List<DeliveryRequest> requests,
  }) => _refreshRoute(location: location, requests: requests);

  void selectRoute(int index) {
    if (index < 0 || index >= _routes.length || index == _selectedIndex) return;
    _selectedIndex = index;
    _state = RiderRouteState.ready;
    _notify();
    unawaited(_cache.save(_routes, _selectedIndex));
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
