part of 'rider_sign_up_controller.dart';

extension RiderSignUpControllerSteps on RiderSignUpController {
  bool get canContinue {
    final error = RiderSignUpValidator.stepError(
      draft: _draft,
      step: _draft.step,
      licenseNumber: _licenseNumber,
      password: _password,
      confirmPassword: _confirmPassword,
      requireCoordinates: _draft.step != RiderSignUpStep.address,
      requirePassword: !emailVerified,
    );
    final checking = switch (_draft.step) {
      RiderSignUpStep.account =>
        !emailVerified &&
            availabilityFor(RiderSignUpFields.email) ==
                RiderFieldAvailability.checking,
      RiderSignUpStep.personal =>
        availabilityFor(RiderSignUpFields.mobile) !=
            RiderFieldAvailability.available,
      _ => false,
    };
    return error == null && !checking;
  }

  Future<bool> continueToNextStep() async {
    if (!canContinue) {
      _showStepErrors = true;
      _refresh();
      return false;
    }
    if (_draft.step == RiderSignUpStep.address &&
        !await _captureCurrentLocation()) {
      _showStepErrors = true;
      _refresh();
      return false;
    }
    final nextIndex = _draft.step.index + 1;
    if (nextIndex >= RiderSignUpStep.values.length) return true;
    _draft = _draft.copyWith(step: RiderSignUpStep.values[nextIndex]);
    _showStepErrors = false;
    await saveNow();
    _refresh();
    return true;
  }

  Future<bool> _captureCurrentLocation() async {
    if (_capturingLocation) return false;
    _capturingLocation = true;
    _error = null;
    _refresh();
    try {
      if (!await _gpsGateway.isServiceEnabled()) {
        await _gpsGateway.openLocationSettings();
        _error = 'Turn on location services, then try continuing again.';
        return false;
      }
      var permission = await _gpsGateway.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await _gpsGateway.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        _error = 'Allow location access so we can capture your exact location.';
        return false;
      }
      if (permission == LocationPermission.deniedForever) {
        await _gpsGateway.openAppSettings();
        _error =
            'Allow location permission in app settings, then try continuing again.';
        return false;
      }
      if (await _gpsGateway.getAccuracyStatus() ==
          LocationAccuracyStatus.reduced) {
        await _gpsGateway.openAppSettings();
        _error = 'Enable precise location, then try continuing again.';
        return false;
      }
      final position = await _gpsGateway.currentPosition(
        settings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 15),
        ),
      );
      updateLocation(
        label: _addressLabel(),
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
        capturedAt: position.timestamp,
      );
      return true;
    } on TimeoutException {
      _error = 'Location capture timed out. Please try continuing again.';
      return false;
    } catch (_) {
      _error = 'We could not capture your exact location. Please try again.';
      return false;
    } finally {
      _capturingLocation = false;
      _refresh();
    }
  }

  String _addressLabel() => RiderAddress.format(
    addressLine: _draft.value(RiderSignUpFields.addressLine),
    barangay: _draft.value(RiderSignUpFields.barangay),
    cityMunicipality: _draft.value(RiderSignUpFields.cityMunicipality),
    province: _draft.value(RiderSignUpFields.province),
    postalCode: _draft.value(RiderSignUpFields.postalCode),
  );

  Future<void> previousStep() async {
    if (_draft.step == RiderSignUpStep.account) return;
    _draft = _draft.copyWith(
      step: RiderSignUpStep.values[_draft.step.index - 1],
    );
    _showStepErrors = false;
    await saveNow();
    _refresh();
  }

  Future<void> editStep(RiderSignUpStep step) async {
    _draft = _draft.copyWith(step: step);
    _showStepErrors = false;
    await saveNow();
    _refresh();
  }

  Future<void> resumeVerifiedEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    _draft = _draft.withValue(RiderSignUpFields.email, normalizedEmail);
    if (_draft.step == RiderSignUpStep.account) {
      _draft = _draft.copyWith(step: RiderSignUpStep.personal);
    }
    markEmailVerified(normalizedEmail);
    await saveNow();
  }
}
