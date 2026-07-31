import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request_metadata.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_matching_context.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_request_query.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';

enum RiderRequestRejection {
  unauthenticated,
  riderUnavailable,
  locationUnavailable,
  poorGpsAccuracy,
  registeredLocationMissing,
  serviceAreaMissing,
  invalidServiceRadius,
  activeDeliveryLimit,
  globallyUnavailable,
  outsideServiceArea,
  outsideServiceRadius,
  vehicleIncompatible,
  capacityUnknown,
  overweight,
  handlingIncompatible,
  pickupDeadlineUnreachable,
  deliveryDeadlineUnreachable,
}

RiderRequestRejection? riderRequestRejection(
  DeliveryRequest request,
  RiderMatchingContext rider, {
  DateTime? at,
  bool requireCurrentGps = true,
}) {
  final now = at ?? DateTime.now();
  if (rider.riderId.trim().isEmpty) {
    return RiderRequestRejection.unauthenticated;
  }
  final continuingBatch =
      rider.availability.isHandlingDelivery &&
      rider.activeDeliveryCount > 0 &&
      rider.activeDeliveryCount < rider.maximumActiveDeliveries;
  if (!rider.availability.canReceiveRequests && !continuingBatch) {
    return RiderRequestRejection.riderUnavailable;
  }
  final serviceArea = rider.registeredServiceArea;
  if (!serviceArea.hasName) return RiderRequestRejection.serviceAreaMissing;
  if (!serviceArea.hasCoordinates) {
    return RiderRequestRejection.registeredLocationMissing;
  }
  if (!serviceArea.hasValidRadius) {
    return RiderRequestRejection.invalidServiceRadius;
  }
  if (rider.location == null &&
      (requireCurrentGps || !rider.usesRegisteredLocationEstimate)) {
    return RiderRequestRejection.locationUnavailable;
  }
  if (rider.location != null && !rider.hasUsableCurrentGps) {
    return RiderRequestRejection.poorGpsAccuracy;
  }
  if (rider.activeDeliveryCount >= rider.maximumActiveDeliveries) {
    return RiderRequestRejection.activeDeliveryLimit;
  }
  if (!request.isAvailableTo(rider.riderId, at: now)) {
    return RiderRequestRejection.globallyUnavailable;
  }
  if (!serviceArea.matchesArea(request.serviceArea)) {
    return RiderRequestRejection.outsideServiceArea;
  }
  if (!serviceArea.containsPickup(request.pickupLocation)) {
    return RiderRequestRejection.outsideServiceRadius;
  }
  if (request.requiredVehicleTypes.isNotEmpty &&
      !request.requiredVehicleTypes.contains(rider.vehicleType)) {
    return RiderRequestRejection.vehicleIncompatible;
  }
  final weight = request.totalWeightKg ?? request.requiredCapacityKg;
  if (weight != null && rider.capacityKg == null) {
    return RiderRequestRejection.capacityUnknown;
  }
  if (weight != null && weight > rider.capacityKg!) {
    return RiderRequestRejection.overweight;
  }
  for (final requirement in request.handlingRequirements) {
    if (requirement.type.needsProvenVehicleCapability &&
        !rider.handlingCapabilityKeys.contains(requirement.type.name)) {
      return RiderRequestRejection.handlingIncompatible;
    }
  }
  final pickupMinutes = rider.pickupTravelMinutes(request);
  if (pickupMinutes == null ||
      now
          .add(Duration(minutes: pickupMinutes))
          .isAfter(request.pickupDeadline)) {
    return RiderRequestRejection.pickupDeadlineUnreachable;
  }
  final deliveryDeadline = request.deliveryDeadline;
  final deliveryMinutes = request.pickupToDeliveryMinutes;
  final totalMinutes = deliveryMinutes == null
      ? null
      : pickupMinutes + deliveryMinutes;
  if (deliveryDeadline == null ||
      totalMinutes == null ||
      now.add(Duration(minutes: totalMinutes)).isAfter(deliveryDeadline)) {
    return RiderRequestRejection.deliveryDeadlineUnreachable;
  }
  return null;
}
