enum RiderAvailabilitySyncState {
  idle,
  checkingRequirements,
  updating,
  synchronizing,
  error,
}

enum RiderAvailabilityWarning {
  verificationRequired,
  unauthorizedRider,
  noInternet,
  backendUnavailable,
  gpsDisabled,
  locationPermissionDenied,
  locationPermissionDeniedForever,
  approximateLocation,
  poorGpsAccuracy,
  locationTimeout,
  locationUnavailable,
  activeDelivery,
  synchronizationFailed,
}

class RiderAvailabilityUpdateResult {
  const RiderAvailabilityUpdateResult({required this.isSuccess, this.warning});

  const RiderAvailabilityUpdateResult.success()
    : isSuccess = true,
      warning = null;

  const RiderAvailabilityUpdateResult.failure(this.warning) : isSuccess = false;

  final bool isSuccess;
  final RiderAvailabilityWarning? warning;
}
