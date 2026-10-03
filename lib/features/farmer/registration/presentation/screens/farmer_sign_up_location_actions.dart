part of 'farmer_sign_up_screen.dart';

extension _FarmerSignUpLocationActions on _FarmerSignUpScreenState {
  Future<void> _captureFarmLocation() async {
    return _captureFarmLocationRequest ??= _captureFarmLocationOnce()
        .whenComplete(() => _captureFarmLocationRequest = null);
  }

  Future<void> _captureFarmLocationOnce() async {
    if (_isCapturingLocation) return;
    _refresh(() => _isCapturingLocation = true);
    try {
      if (!await _gpsGateway.isServiceEnabled()) {
        await _gpsGateway.openLocationSettings();
        _validateFarmLocationSilently();
        return;
      }

      var permission = await _gpsGateway.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await _gpsGateway.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        _validateFarmLocationSilently();
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        await _gpsGateway.openAppSettings();
        _validateFarmLocationSilently();
        return;
      }
      if (await _gpsGateway.getAccuracyStatus() ==
          LocationAccuracyStatus.reduced) {
        await _gpsGateway.openAppSettings();
        _validateFarmLocationSilently();
        return;
      }

      final position = await _gpsGateway.currentPosition(
        settings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (!mounted) return;
      _refresh(() {
        _controllers.setFarmCoordinates(
          latitudeValue: position.latitude,
          longitudeValue: position.longitude,
        );
        _validateCurrent(showEmpty: false);
      });
    } on TimeoutException {
      _validateFarmLocationSilently();
    } catch (_) {
      _validateFarmLocationSilently();
    } finally {
      if (mounted) _refresh(() => _isCapturingLocation = false);
    }
  }

  void _validateFarmLocationSilently() {
    if (!mounted) return;
    _refresh(() => _validateCurrent(showEmpty: false));
  }
}
