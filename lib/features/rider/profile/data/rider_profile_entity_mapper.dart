import 'package:agresell_app/features/rider/profile/domain/rider.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_vehicle.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_document.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_location.dart';

RiderProfile riderProfileFromEntities(
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
    capacityKg:
        rider.capacityKg ??
        (vehicle.capacityKg > 0 ? vehicle.capacityKg : null),
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
