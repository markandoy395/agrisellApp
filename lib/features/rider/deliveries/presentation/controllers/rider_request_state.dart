enum RiderRequestLoadState { loading, ready, error, offline }

enum RiderRequestAccessState {
  eligible,
  unauthenticated,
  offline,
  noInternet,
  backendUnavailable,
  gpsDisabled,
  permissionDenied,
  poorGpsAccuracy,
  locationUnavailable,
  registeredLocationMissing,
  serviceAreaMissing,
  invalidServiceRadius,
  outsideRegisteredServiceArea,
  activeDeliveryLimit,
}

extension RiderRequestAccessStateDetails on RiderRequestAccessState {
  bool get canPreviewRequests => switch (this) {
    RiderRequestAccessState.eligible ||
    RiderRequestAccessState.outsideRegisteredServiceArea ||
    RiderRequestAccessState.gpsDisabled ||
    RiderRequestAccessState.permissionDenied ||
    RiderRequestAccessState.poorGpsAccuracy ||
    RiderRequestAccessState.locationUnavailable => true,
    _ => false,
  };

  bool get canAcceptRequests =>
      this == RiderRequestAccessState.eligible ||
      this == RiderRequestAccessState.outsideRegisteredServiceArea;

  bool get usesRegisteredLocationEstimate =>
      canPreviewRequests && !canAcceptRequests;
}
