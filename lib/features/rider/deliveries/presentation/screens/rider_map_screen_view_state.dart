part of 'rider_map_screen.dart';

extension _RiderMapScreenViewState on _RiderMapScreenState {
  Future<void> _restoreMapView() async {
    _restoredView = await _viewCache.load();
    _viewRestoreCompleted = true;
    if (_mapReady) _applyRestoredView();
  }

  void _onMapReady() {
    _mapReady = true;
    if (_viewRestoreCompleted) _applyRestoredView();
  }

  void _applyRestoredView() {
    final view = _restoredView;
    final location = _locationController.location;
    if (view == null ||
        location == null ||
        !RiderMapCameraPolicy.canMoveCamera(_mapController.camera)) {
      return;
    }
    final zoom = RiderMapCameraPolicy.safeZoom(view.zoom);
    final rotation = RiderMapCameraPolicy.safeRotation(view.rotation);
    _mapController.moveAndRotate(
      LatLng(location.latitude, location.longitude),
      zoom,
      rotation,
    );
    _mapZoom = zoom;
    _restoredView = null;
  }

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    if (hasGesture) _followRider = false;
    if (!RiderMapCameraPolicy.isCameraValid(camera)) return;
    if ((camera.zoom - _mapZoom).abs() >= 0.25 && mounted) {
      _updateMapZoom(camera.zoom);
    }
    if (!_viewRestoreCompleted) return;
    _pendingView = RiderMapView(
      latitude: camera.center.latitude,
      longitude: camera.center.longitude,
      zoom: camera.zoom,
      rotation: camera.rotation,
    );
    _viewSaveDebounce?.cancel();
    _viewSaveDebounce = Timer(const Duration(milliseconds: 600), () {
      final view = _pendingView;
      _pendingView = null;
      if (view != null) unawaited(_viewCache.save(view));
    });
  }
}
