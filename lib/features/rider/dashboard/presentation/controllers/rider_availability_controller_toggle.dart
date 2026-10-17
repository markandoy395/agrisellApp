part of 'rider_availability_controller.dart';

extension RiderAvailabilityControllerToggle on RiderAvailabilityController {
  Future<RiderAvailabilityUpdateResult> _setOnline(bool value) async {
    _warning = null;
    _syncState = RiderAvailabilitySyncState.checkingRequirements;
    _notify();
    final guard = await _checkToggleRequirements(value);
    if (guard != null) return _fail(guard);
    final target = value
        ? RiderAvailability.onlineAvailable
        : RiderAvailability.offline;
    _syncState = RiderAvailabilitySyncState.updating;
    _notify();
    try {
      if (value && !await locationController.publishCurrentLocation()) {
        return _fail(RiderAvailabilityWarning.synchronizationFailed);
      }
      await _repository.saveAvailability(_riderId!, target);
      _lastObservedAvailability = target;
      await deliveryController.applyAuthoritativeAvailability(
        target,
        loadRequests: false,
      );
      _syncState = RiderAvailabilitySyncState.idle;
      _notify();
      // Nearby requests have their own loading/error state. They should not
      // keep a successfully saved availability change waiting.
      if (value && !_isDisposed) {
        unawaited(deliveryController.load(riderId: _riderId!));
      }
      return const RiderAvailabilityUpdateResult.success();
    } catch (_) {
      return _fail(RiderAvailabilityWarning.synchronizationFailed);
    }
  }

  Future<RiderAvailabilityWarning?> _checkToggleRequirements(
    bool goingOnline,
  ) async {
    if (deliveryController.status.verificationStatus !=
        RiderVerificationStatus.verified) {
      return RiderAvailabilityWarning.verificationRequired;
    }
    if (_riderId == null || _riderId!.isEmpty) {
      return RiderAvailabilityWarning.unauthorizedRider;
    }
    if (deliveryController.hasActiveDelivery) {
      return RiderAvailabilityWarning.activeDelivery;
    }
    final connectivity = await _checkConnectivity();
    _setInternetStatus(connectivity);
    if (connectivity == RiderInternetStatus.backendUnavailable) {
      return RiderAvailabilityWarning.backendUnavailable;
    }
    if (connectivity != RiderInternetStatus.online) {
      return RiderAvailabilityWarning.noInternet;
    }
    if (!goingOnline) return null;
    await locationController.refresh(requestPermission: true);
    return switch (gpsStatus) {
      RiderGpsStatus.disabled => RiderAvailabilityWarning.gpsDisabled,
      RiderGpsStatus.permissionDenied =>
        RiderAvailabilityWarning.locationPermissionDenied,
      RiderGpsStatus.permissionDeniedForever =>
        RiderAvailabilityWarning.locationPermissionDeniedForever,
      RiderGpsStatus.approximateLocation =>
        RiderAvailabilityWarning.approximateLocation,
      RiderGpsStatus.timedOut => RiderAvailabilityWarning.locationTimeout,
      RiderGpsStatus.unavailable ||
      RiderGpsStatus.checking => RiderAvailabilityWarning.locationUnavailable,
      RiderGpsStatus.poorAccuracy => _markPoorAccuracy(),
      RiderGpsStatus.ready => null,
    };
  }

  RiderAvailabilityUpdateResult _fail(RiderAvailabilityWarning warning) {
    _warning = warning;
    _syncState = RiderAvailabilitySyncState.error;
    _notify();
    return RiderAvailabilityUpdateResult.failure(warning);
  }
}
