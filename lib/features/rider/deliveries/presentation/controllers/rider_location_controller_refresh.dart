part of 'rider_location_controller.dart';

extension RiderLocationControllerRefresh on RiderLocationController {
  Future<void> _refreshLocation({bool requestPermission = false}) async {
    if (_isDisposed) return;
    final isInitialLoad = _location == null;
    if (isInitialLoad) _state = RiderLocationState.loading;
    _errorMessage = null;
    if (isInitialLoad) _notify();
    try {
      if (!await _gateway.isServiceEnabled()) {
        _setUnavailableState(RiderLocationState.serviceDisabled);
        return;
      }
      var permission = await _gateway.checkPermission();
      if (permission == LocationPermission.denied && requestPermission) {
        permission = await _gateway.requestPermission();
      }
      _permission = permission;
      if (permission == LocationPermission.denied) {
        _setUnavailableState(RiderLocationState.permissionDenied);
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        _setUnavailableState(RiderLocationState.permissionDeniedForever);
        return;
      }
      try {
        _isApproximate =
            await _gateway.getAccuracyStatus() ==
            LocationAccuracyStatus.reduced;
      } on Exception {
        _isApproximate = false;
      }
      if (_isDisposed) return;
      final position = await _gateway.currentPosition(
        settings: _currentLocationSettings,
      );
      if (!_isUsablePositionSample(position)) {
        _setError(
          'A current GPS fix could not be retrieved. Please try again.',
        );
        return;
      }
      _setPosition(position);
    } on TimeoutException {
      _setError(
        'Location took too long. Check your signal and try again.',
        state: RiderLocationState.timedOut,
      );
    } on Exception {
      _setError('Current location could not be retrieved.');
    }
  }
}
