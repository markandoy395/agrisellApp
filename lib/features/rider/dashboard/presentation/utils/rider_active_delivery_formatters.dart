import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';

abstract final class RiderActiveDeliveryFormatters {
  static bool canOpenMap(DeliveryRequest request) =>
      request.pickupLocation.hasCoordinates ||
      request.deliveryLocation.hasCoordinates;

  static String deadline(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final suffix = value.hour < 12 ? 'AM' : 'PM';
    return '${value.month}/${value.day} $hour:$minute $suffix';
  }

  static String nextAction(DeliveryStage stage) => switch (stage) {
    DeliveryStage.accepted => 'Start the route to pickup',
    DeliveryStage.goingToPickup => 'Navigate to the pickup location',
    DeliveryStage.arrivedAtPickup => 'Confirm pickup when the product is ready',
    DeliveryStage.pickedUp => 'Start the route to the buyer',
    DeliveryStage.goingToDelivery => 'Navigate to the delivery location',
    DeliveryStage.arrivedAtDelivery => 'Confirm the buyer handoff',
    DeliveryStage.delivered => 'Complete the delivery record',
    _ => 'Open the delivery for the next available action',
  };
}
