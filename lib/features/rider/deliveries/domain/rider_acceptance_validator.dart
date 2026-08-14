import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_acceptance.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_acceptance_state.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_request_matcher.dart';

DeliveryAcceptanceFailure? validateDeliveryAcceptance({
  required DeliveryRequest request,
  required RiderAcceptanceState? rider,
  required DateTime now,
}) {
  if (request.assignedRiderId != null) {
    return DeliveryAcceptanceFailure.alreadyAssigned;
  }
  if (request.expiresAt != null && !request.expiresAt!.isAfter(now)) {
    return DeliveryAcceptanceFailure.expired;
  }
  if (request.stage != DeliveryStage.readyForPickup ||
      (request.availableAt != null && request.availableAt!.isAfter(now))) {
    return DeliveryAcceptanceFailure.productNotReady;
  }
  if (request.reservedRiderId != null &&
      request.reservedRiderId != rider?.riderId &&
      request.reservedUntil != null &&
      request.reservedUntil!.isAfter(now)) {
    return DeliveryAcceptanceFailure.transactionConflict;
  }
  if (rider == null || !rider.isAllowedToDeliver) {
    return DeliveryAcceptanceFailure.riderNotAllowed;
  }
  final isActiveManualOfflineBooking =
      rider.availability == RiderAvailability.offline &&
      request.reservedRiderId == rider.riderId &&
      request.reservedUntil != null &&
      request.reservedUntil!.isAfter(now);
  if (rider.availability == RiderAvailability.offline &&
      !isActiveManualOfflineBooking) {
    return DeliveryAcceptanceFailure.riderOffline;
  }
  if (rider.activeDeliveryCount >= rider.maximumActiveDeliveries) {
    return DeliveryAcceptanceFailure.activeDeliveryLimit;
  }
  final continuingBatch =
      rider.availability.isHandlingDelivery &&
      rider.activeDeliveryCount > 0 &&
      rider.activeDeliveryCount < rider.maximumActiveDeliveries;
  if (rider.availability != RiderAvailability.onlineAvailable &&
      !continuingBatch &&
      !isActiveManualOfflineBooking) {
    return DeliveryAcceptanceFailure.riderUnavailable;
  }
  if (rider.conflictingDeliveryId != null && !continuingBatch) {
    return DeliveryAcceptanceFailure.conflictingAssignment;
  }
  if (rider.serviceArea.trim().isNotEmpty &&
      !rider.matching.registeredServiceArea.matchesArea(request.serviceArea)) {
    return DeliveryAcceptanceFailure.serviceAreaMismatch;
  }
  return _matchingFailure(
    riderRequestRejection(
      request,
      rider.matching,
      at: now,
      allowReservedOffline: isActiveManualOfflineBooking,
    ),
  );
}

DeliveryAcceptanceFailure? _matchingFailure(RiderRequestRejection? rejection) {
  return switch (rejection) {
    null => null,
    RiderRequestRejection.unauthenticated =>
      DeliveryAcceptanceFailure.riderNotAllowed,
    RiderRequestRejection.riderUnavailable =>
      DeliveryAcceptanceFailure.riderUnavailable,
    RiderRequestRejection.locationUnavailable ||
    RiderRequestRejection.poorGpsAccuracy =>
      DeliveryAcceptanceFailure.locationUnacceptable,
    RiderRequestRejection.registeredLocationMissing ||
    RiderRequestRejection.serviceAreaMissing ||
    RiderRequestRejection.invalidServiceRadius =>
      DeliveryAcceptanceFailure.serviceAreaMismatch,
    RiderRequestRejection.activeDeliveryLimit =>
      DeliveryAcceptanceFailure.activeDeliveryLimit,
    RiderRequestRejection.globallyUnavailable =>
      DeliveryAcceptanceFailure.transactionConflict,
    RiderRequestRejection.outsideServiceArea ||
    RiderRequestRejection.outsideServiceRadius =>
      DeliveryAcceptanceFailure.serviceAreaMismatch,
    RiderRequestRejection.vehicleIncompatible =>
      DeliveryAcceptanceFailure.vehicleMismatch,
    RiderRequestRejection.capacityUnknown || RiderRequestRejection.overweight =>
      DeliveryAcceptanceFailure.capacityMismatch,
    RiderRequestRejection.handlingIncompatible ||
    RiderRequestRejection.pickupDeadlineUnreachable ||
    RiderRequestRejection.deliveryDeadlineUnreachable =>
      DeliveryAcceptanceFailure.riderIneligible,
  };
}
