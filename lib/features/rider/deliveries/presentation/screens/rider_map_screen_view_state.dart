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
    if (view == null) return;
    _mapController.moveAndRotate(
      LatLng(view.latitude, view.longitude),
      view.zoom,
      view.rotation,
    );
    _restoredView = null;
  }

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
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
