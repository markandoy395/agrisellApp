class FarmerRiderCandidate {
  const FarmerRiderCandidate({
    required this.id,
    required this.name,
    required this.barangay,
    required this.municipality,
    required this.sameBarangay,
    required this.rating,
    required this.completedDeliveries,
    this.sameMunicipality = false,
    this.availabilityStatus = 'online',
    this.isRequestable = true,
    this.profilePhotoPath,
    this.profileImageUrl,
    this.distanceKm,
    this.estimatedArrivalMinutes,
    this.currentLocationUpdatedAt,
    this.locationIsFresh = false,
    this.destinationSupported = true,
    this.deliveryDistanceKm,
    this.activeDeliveryCount = 0,
    this.proposedDeliveryFee,
  });

  final String id;
  final String name;
  final String? profilePhotoPath;
  final String? profileImageUrl;
  final String barangay;
  final String municipality;
  final bool sameBarangay;
  final bool sameMunicipality;
  final String availabilityStatus;
  final bool isRequestable;
  final double? distanceKm;
  final int? estimatedArrivalMinutes;
  final DateTime? currentLocationUpdatedAt;
  final bool locationIsFresh;
  final bool destinationSupported;
  final double? deliveryDistanceKm;
  final int activeDeliveryCount;
  final double rating;
  final int completedDeliveries;
  final double? proposedDeliveryFee;

  bool get isOfflineManualCandidate => availabilityStatus == 'offline';
  bool get hasRequestableAvailability =>
      availabilityStatus == 'online' ||
      availabilityStatus == 'busy' ||
      isOfflineManualCandidate;
  bool get isAvailable => availabilityStatus != 'offline' && canReceiveRequest;
  bool get canReceiveRequest =>
      hasRequestableAvailability && isRequestable && destinationSupported;

  FarmerRiderCandidate copyWith({
    String? profileImageUrl,
    double? proposedDeliveryFee,
  }) => FarmerRiderCandidate(
    id: id,
    name: name,
    profilePhotoPath: profilePhotoPath,
    profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    barangay: barangay,
    municipality: municipality,
    sameBarangay: sameBarangay,
    sameMunicipality: sameMunicipality,
    availabilityStatus: availabilityStatus,
    isRequestable: isRequestable,
    distanceKm: distanceKm,
    estimatedArrivalMinutes: estimatedArrivalMinutes,
    currentLocationUpdatedAt: currentLocationUpdatedAt,
    locationIsFresh: locationIsFresh,
    destinationSupported: destinationSupported,
    deliveryDistanceKm: deliveryDistanceKm,
    activeDeliveryCount: activeDeliveryCount,
    rating: rating,
    completedDeliveries: completedDeliveries,
    proposedDeliveryFee: proposedDeliveryFee ?? this.proposedDeliveryFee,
  );
}

const offlineRiderBookingMinutes = 45;

List<FarmerRiderCandidate> eligibleRidersNearestFirst(
  Iterable<FarmerRiderCandidate> riders,
) {
  final sorted =
      riders.where((rider) => rider.canReceiveRequest).toList(growable: true)
        ..sort(_compareEligibleRiders);
  return List.unmodifiable(sorted);
}

int _compareEligibleRiders(
  FarmerRiderCandidate left,
  FarmerRiderCandidate right,
) {
  final leftDistance = left.distanceKm;
  final rightDistance = right.distanceKm;
  if (leftDistance != null && rightDistance != null) {
    final distanceOrder = leftDistance.compareTo(rightDistance);
    if (distanceOrder != 0) return distanceOrder;
  } else if (leftDistance != null) {
    return -1;
  } else if (rightDistance != null) {
    return 1;
  }
  final workloadOrder = left.activeDeliveryCount.compareTo(
    right.activeDeliveryCount,
  );
  if (workloadOrder != 0) return workloadOrder;
  final ratingOrder = right.rating.compareTo(left.rating);
  if (ratingOrder != 0) return ratingOrder;
  final deliveryOrder = right.completedDeliveries.compareTo(
    left.completedDeliveries,
  );
  return deliveryOrder != 0 ? deliveryOrder : left.name.compareTo(right.name);
}

class FarmerRiderDeliveryDetails {
  const FarmerRiderDeliveryDetails({
    required this.orderId,
    required this.deliveryId,
    required this.pickupAddress,
    required this.pickupBarangay,
    required this.pickupMunicipality,
    required this.destination,
    required this.goodsSummary,
    required this.requestedSchedule,
    this.destinationLatitude,
    this.destinationLongitude,
    this.routeDistanceKm,
    this.estimatedDeliveryMinutes,
    this.proposedDeliveryFee,
  });

  final String orderId;
  final String deliveryId;
  final String pickupAddress;
  final String pickupBarangay;
  final String pickupMunicipality;
  final String destination;
  final String goodsSummary;
  final DateTime requestedSchedule;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final double? routeDistanceKm;
  final int? estimatedDeliveryMinutes;
  final double? proposedDeliveryFee;
}

class FarmerRiderSelectionData {
  const FarmerRiderSelectionData({
    required this.delivery,
    required this.riders,
  });

  final FarmerRiderDeliveryDetails delivery;
  final List<FarmerRiderCandidate> riders;

  bool get hasSameBarangayRiders => riders.any((rider) => rider.sameBarangay);
  bool get hasSameMunicipalityRiders =>
      riders.any((rider) => rider.sameMunicipality);
}
