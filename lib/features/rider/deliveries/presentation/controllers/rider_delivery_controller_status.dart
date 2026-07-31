part of 'rider_delivery_controller.dart';

bool _sameLocationEvidence(
  DeliveryStatusLocation? first,
  DeliveryStatusLocation? second,
) =>
    identical(first, second) ||
    (first != null &&
        second != null &&
        first.latitude == second.latitude &&
        first.longitude == second.longitude &&
        first.accuracyMeters == second.accuracyMeters &&
        first.timestamp == second.timestamp &&
        first.isMocked == second.isMocked &&
        first.isApproximate == second.isApproximate);

extension RiderDeliveryControllerStatus on RiderDeliveryController {
  void updateProfile(RiderProfile? profile) {
    _profile = profile;
    final verification =
        profile?.verificationStatus ?? RiderVerificationStatus.pending;
    _status = _status.copyWith(
      verificationStatus: verification,
      availability: verification == RiderVerificationStatus.verified
          ? _status.availability
          : RiderAvailability.offline,
    );
    if (verification != RiderVerificationStatus.verified) {
      _requests = removeReadyPickupRequests(_requests);
      _loadState = RiderRequestLoadState.offline;
    }
    _notify();
  }

  void setOnline(bool isOnline) {
    if (_status.verificationStatus != RiderVerificationStatus.verified) return;
    if (hasAssignedActiveDelivery(_requests, _riderId ?? '')) return;
    _status = _status.copyWith(
      availability: isOnline
          ? RiderAvailability.onlineAvailable
          : RiderAvailability.offline,
    );
    unawaited(_persistState());
    if (isOnline && _riderId != null) {
      unawaited(load(riderId: _riderId!));
      return;
    }
    if (!isOnline) {
      _requests = removeReadyPickupRequests(_requests);
      _loadState = RiderRequestLoadState.offline;
    }
    _notify();
  }
}
