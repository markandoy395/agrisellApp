part of 'rider_route_controller.dart';

class _QueuedRouteRequest {
  const _QueuedRouteRequest({
    required this.generation,
    required this.requestId,
    required this.destinationKey,
    required this.origin,
    required this.destination,
    this.includeAlternatives = false,
  });

  final int generation;
  final String requestId;
  final String destinationKey;
  final DeliveryRoutePoint origin;
  final DeliveryRoutePoint destination;
  final bool includeAlternatives;
}

extension _RiderRouteRequests on RiderRouteController {
  Future<void> _refreshRoute({
    required RiderDeviceLocation location,
    required List<DeliveryRequest> requests,
    bool includeAlternatives = false,
  }) async {
    if (!_isOnline) {
      _errorMessage = 'Connect to the internet to refresh the road route.';
      _state = _routes.isEmpty ? RiderRouteState.error : RiderRouteState.stale;
      _notify();
      return;
    }
    final mapDestination = _mapDestination;
    if (mapDestination != null && _mapDestinationId != null) {
      await _requestRoutes(
        requestId: 'farm:${_mapDestinationId!}',
        destinationKey: 'farm:${_mapDestinationId!}',
        origin: DeliveryRoutePoint(
          latitude: location.latitude,
          longitude: location.longitude,
        ),
        destination: mapDestination,
        force: true,
        includeAlternatives: includeAlternatives,
      );
      return;
    }
    final request = selectRiderRouteTarget(requests, _selectedRequestId);
    if (request == null) return;
    final destination = riderRouteDestination(request);
    if (destination == null) return;
    await _requestRoutes(
      requestId: request.id,
      destinationKey:
          '${request.id}:${riderRouteUsesDeliveryLocation(request) ? 'delivery' : 'pickup'}',
      origin: DeliveryRoutePoint(
        latitude: location.latitude,
        longitude: location.longitude,
      ),
      destination: destination,
      force: true,
      includeAlternatives: includeAlternatives,
    );
  }

  Future<void> _requestRoutes({
    required String requestId,
    required String destinationKey,
    required DeliveryRoutePoint origin,
    required DeliveryRoutePoint destination,
    bool force = false,
    bool includeAlternatives = false,
  }) {
    final running = _requestInFlight;
    if (running != null &&
        _inFlightDestinationKey == destinationKey &&
        !force) {
      return running;
    }
    final request = _QueuedRouteRequest(
      generation: ++_latestGeneration,
      requestId: requestId,
      destinationKey: destinationKey,
      origin: origin,
      destination: destination,
      includeAlternatives: includeAlternatives,
    );
    _pendingRequest = request;
    if (running != null) return running;
    late final Future<void> operation;
    operation = _drainRequests().whenComplete(() {
      if (identical(_requestInFlight, operation)) {
        _requestInFlight = null;
        _inFlightDestinationKey = null;
        _notify();
      }
    });
    _requestInFlight = operation;
    return operation;
  }

  Future<void> _drainRequests() async {
    while (_pendingRequest != null) {
      final request = _pendingRequest!;
      _pendingRequest = null;
      _inFlightDestinationKey = request.destinationKey;
      await _loadRoutes(request);
    }
  }

  Future<void> _loadRoutes(_QueuedRouteRequest request) async {
    if (_isDisposed) return;
    _lastDestinationKey = request.destinationKey;
    _lastAttempt = DateTime.now();
    _lastRequestOrigin = request.origin;
    _state = RiderRouteState.loading;
    _errorMessage = null;
    _notify();
    try {
      final service =
          request.includeAlternatives && _service is OsrmRiderRoutingService
          ? _service.withAlternatives()
          : _service;
      final routes = await service
          .findRoutes(
            requestId: request.requestId,
            destinationKey: request.destinationKey,
            origin: request.origin,
            destination: request.destination,
          )
          .timeout(requestTimeout);
      if (request.generation != _latestGeneration) return;
      if (routes.isEmpty) {
        throw const RiderRoutingException('No road route found.');
      }
      final preference = activeRoute?.preference;
      _routes = routes;
      _selectedIndex = preference == null
          ? 0
          : routes.indexWhere((route) => route.preference == preference);
      if (_selectedIndex < 0) _selectedIndex = 0;
      _state = RiderRouteState.ready;
      _routeUpdatedAt = DateTime.now();
      // Rendering a valid road route must not wait for platform storage.
      _notify();
      unawaited(_saveRoutes());
    } on Exception catch (error) {
      if (request.generation != _latestGeneration) return;
      _state = _routes.isEmpty ? RiderRouteState.error : RiderRouteState.stale;
      _errorMessage = error is TimeoutException
          ? 'Route request timed out. Tap Retry route to try again.'
          : error is RiderRoutingException
          ? error.message
          : 'Route update failed. The saved route will remain visible.';
    }
    if (request.generation == _latestGeneration) _notify();
  }

  Future<void> _saveRoutes() async {
    try {
      await _cache
          .save(_routes, _selectedIndex)
          .timeout(const Duration(seconds: 2));
    } on Exception {
      // A storage failure does not invalidate an already calculated road route.
    }
  }
}
