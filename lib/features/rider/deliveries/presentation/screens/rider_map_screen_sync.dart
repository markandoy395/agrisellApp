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
    _scheduleRoadAccessSync();
    unawaited(_updateNavigation(location));
  }

  Future<void> _updateNavigation(RiderDeviceLocation location) async {
    await _routeController.synchronize(
      location: location,
      requests: widget.deliveryController.routeOrderedRequests,
      navigationActive: widget.isActive && _navigationActive,
    );
    _scheduleRoadAccessSync();
    if (!_mapReady ||
        !_followRider ||
        !widget.isActive ||
        !RiderMapCameraPolicy.canMoveCamera(_mapController.camera)) {
      return;
    }
    final point = _routeController.displayPoint(location);
    if (!RiderMapCameraPolicy.isCoordinateValid(
      point.latitude,
      point.longitude,
    )) {
      return;
    }
    final zoom = RiderMapCameraPolicy.safeZoom(
      _mapController.camera.zoom,
      minimum: 15,
      maximum: 18,
    );
    final heading = location.headingDegrees;
    if (_navigationActive &&
        location.speedMetersPerSecond >= 0.5 &&
        heading.isFinite &&
        heading >= 0 &&
        heading <= 360) {
      _mapController.moveAndRotate(
        LatLng(point.latitude, point.longitude),
        zoom,
        RiderMapCameraPolicy.safeRotation(heading),
      );
    } else {
      _mapController.move(LatLng(point.latitude, point.longitude), zoom);
    }
  }

  void _syncNearbySearch() {
    if (!widget.isActive) return;
    final location = _locationController.location;
    if (location == null) return;
    final search = RiderDeliverySearch(
      latitude: location.latitude,
      longitude: location.longitude,
      radiusKm:
          widget.profile?.serviceRadiusKm ??
          RiderDeliverySearch.defaultRadiusKm,
    );
    final previous = _lastNearbySearch;
    if (previous != null && !search.hasMovedBeyond(previous)) return;
    _lastNearbySearch = search;
    unawaited(widget.deliveryController.updateNearbySearch(search));
    unawaited(_loadNearbyFarms(search));
  }

  Future<void> _refreshMapDiscovery() async {
    _lastNearbySearch = null;
    await _locationController.refresh();
    if (mounted) _syncNearbySearch();
  }
}
