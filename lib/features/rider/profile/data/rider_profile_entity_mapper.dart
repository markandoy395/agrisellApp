part of 'rider_registration_service.dart';

RiderProfile _profileFromEntities(
  Rider rider,
  RiderVehicle vehicle,
  List<RiderDocument> documents,
  RiderLocation? location,
  String? photoUrl,
) {
  return RiderProfile(
    id: rider.riderId,
    logisticCompanyId: rider.logisticsCompanyId,
    licenseNumber: rider.licenseNumber,
    fullName: rider.fullName,
    firstName: rider.firstName,
    lastName: rider.lastName,
    vehicleType: RiderVehicleType.values.firstWhere(
      (item) => item.name == rider.vehicleType,
      orElse: () => RiderVehicleType.other,
    ),
    vehiclePlateNumber: rider.vehiclePlateNumber.startsWith('NO-PLATE-')
        ? 'No plate required'
        : rider.vehiclePlateNumber,
    availabilityStatus: _operationalAvailability(rider),
    rating: rider.rating,
    contactNumber: rider.contactNumber,
    email: rider.email,
    gpsLatitude: rider.gpsLatitude,
    gpsLongitude: rider.gpsLongitude,
    address: rider.locationLabel,
    addressLine: rider.addressLine,
    barangay: rider.barangay,
    cityMunicipality: rider.cityMunicipality,
    province: rider.province,
    postalCode: rider.postalCode,
    totalDeliveries: rider.totalDeliveries,
    maximumActiveDeliveries: rider.maximumActiveDeliveries,
    employmentStatus: rider.employmentStatus,
    profilePhotoUrl: photoUrl,
  );
}

RiderAvailability _operationalAvailability(Rider rider) {
  if (rider.availabilityStatus == RiderDatabaseAvailability.offline) {
    return RiderAvailability.offline;
  }
  if (rider.availabilityStatus == RiderDatabaseAvailability.online) {
    return RiderAvailability.onlineAvailable;
  }
  return switch (rider.deliveryStatus) {
    RiderDeliveryProgress.assigned => RiderAvailability.deliveryReserved,
    RiderDeliveryProgress.goingToPickup => RiderAvailability.goingToPickup,
    RiderDeliveryProgress.arrivedAtPickup => RiderAvailability.waitingAtPickup,
    RiderDeliveryProgress.pickedUp => RiderAvailability.productPickedUp,
    RiderDeliveryProgress.goingToBuyer => RiderAvailability.goingToBuyer,
    RiderDeliveryProgress.arrivedAtDelivery =>
      RiderAvailability.waitingAtDeliveryLocation,
    RiderDeliveryProgress.waiting ||
    RiderDeliveryProgress.completed => RiderAvailability.onlineAvailable,
  };
}
