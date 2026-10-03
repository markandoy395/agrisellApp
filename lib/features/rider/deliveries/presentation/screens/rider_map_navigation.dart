part of 'rider_map_screen.dart';

extension _RiderMapNavigation on _RiderMapScreenState {
  Future<void> _startNavigation(DeliveryRequest request) async {
    final location = _locationController.location;
    if (location == null) return;
    final source = _roadAccessSourceForRequest(
      request,
      RiderMapMarkerKind.assignedDelivery,
    );
    if (_selectedRoadAccessSource?.id != source?.id) {
      _selectRoadAccessSource(source);
    }
    _updateMapState(() {
      _navigationActive = true;
      _followRider = true;
    });
    await _routeController.selectRequest(
      requestId: request.id,
      location: location,
      requests: widget.deliveryController.routeOrderedRequests,
    );
    _scheduleRoadAccessSync();
    _fitActiveRoute();
  }

  void _fitActiveRoute() {
    if (!mounted) return;
    final route = _routeController.activeRoute;
    if (_mapReady &&
        route != null &&
        RiderMapCameraPolicy.canMoveCamera(_mapController.camera)) {
      final coordinates = route.points
          .where(
            (point) => RiderMapCameraPolicy.isCoordinateValid(
              point.latitude,
              point.longitude,
            ),
          )
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList(growable: false);
      final padding = RiderMapCameraPolicy.routeFitPadding(
        _mapController.camera.nonRotatedSize,
      );
      if (coordinates.length < 2 || padding == null) return;
      _mapController.fitCamera(
        CameraFit.coordinates(
          coordinates: coordinates,
          padding: padding,
          maxZoom: 16,
        ),
      );
    }
  }

  Future<void> _startFarmNavigation(RiderNearbyFarm farm) async {
    final location = _locationController.location;
    if (location == null) return;
    final source = _roadAccessSourceForFarm(farm);
    final selected = _selectedRoadAccessSource;
    if (selected?.id != source?.id ||
        selected?.point.latitude != source?.point.latitude ||
        selected?.point.longitude != source?.point.longitude) {
      _selectRoadAccessSource(source);
    }
    _updateMapState(() {
      _navigationActive = true;
      _followRider = true;
    });
    await _routeController.selectMapDestination(
      destinationId: farm.id,
      destinationLabel: farm.name,
      destination: DeliveryRoutePoint(
        latitude: farm.latitude,
        longitude: farm.longitude,
      ),
      location: location,
      requests: widget.deliveryController.routeOrderedRequests,
    );
    _scheduleRoadAccessSync();
    _fitActiveRoute();
  }

  void _exitNavigation() {
    _routeController.clear();
    _roadAccessDebounce?.cancel();
    _roadAccessGeneration++;
    _updateMapState(() {
      _navigationActive = false;
      _followRider = true;
      _selectedRoadAccessSource = null;
      _roadAccessConnections = const [];
    });
    _lastRoadAccessFingerprint = null;
    _lastRoadAccessAttempt = null;
    _recenter();
  }

  void _recenter() {
    final location = _locationController.location;
    if (!_mapReady ||
        location == null ||
        !RiderMapCameraPolicy.canMoveCamera(_mapController.camera)) {
      return;
    }
    _followRider = true;
    final point = _routeController.displayPoint(location);
    if (!RiderMapCameraPolicy.isCoordinateValid(
      point.latitude,
      point.longitude,
    )) {
      return;
    }
    _mapController.move(
      LatLng(point.latitude, point.longitude),
      RiderMapCameraPolicy.safeZoom(
        _mapController.camera.zoom,
        minimum: 15,
        maximum: 18,
      ),
    );
  }
}
