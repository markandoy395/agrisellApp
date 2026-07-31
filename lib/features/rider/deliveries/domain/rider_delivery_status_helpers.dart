import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';

bool hasAssignedActiveDelivery(
  Iterable<DeliveryRequest> requests,
  String riderId,
) {
  return requests.any(
    (request) => request.isAssignedTo(riderId) && !request.stage.isTerminal,
  );
}

List<DeliveryRequest> removeReadyPickupRequests(
  Iterable<DeliveryRequest> requests,
) {
  return requests
      .where((request) => request.stage != DeliveryStage.readyForPickup)
      .toList(growable: false);
}

RiderAvailability riderAvailabilityForDeliveryStage(
  DeliveryStage stage,
  RiderAvailability current,
) {
  return switch (stage) {
    DeliveryStage.accepted => RiderAvailability.deliveryReserved,
    DeliveryStage.goingToPickup => RiderAvailability.goingToPickup,
    DeliveryStage.arrivedAtPickup => RiderAvailability.waitingAtPickup,
    DeliveryStage.pickedUp => RiderAvailability.productPickedUp,
    DeliveryStage.goingToDelivery => RiderAvailability.goingToBuyer,
    DeliveryStage.arrivedAtDelivery ||
    DeliveryStage.delivered => RiderAvailability.waitingAtDeliveryLocation,
    DeliveryStage.completed ||
    DeliveryStage.cancelled ||
    DeliveryStage.failed => RiderAvailability.onlineAvailable,
    DeliveryStage.readyForPickup => current,
  };
}
