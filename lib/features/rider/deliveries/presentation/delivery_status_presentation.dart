import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';

extension DeliveryStatusPresentation on DeliveryStatus {
  String get displayLabel => switch (this) {
    DeliveryStatus.pending => 'Pending',
    DeliveryStatus.available => 'Available',
    DeliveryStatus.reserved => 'Reserved',
    DeliveryStatus.accepted => 'Accepted',
    DeliveryStatus.goingToPickup => 'Going to Pickup',
    DeliveryStatus.arrivedAtPickup => 'Arrived at Pickup',
    DeliveryStatus.waitingForProduct => 'Waiting for Product',
    DeliveryStatus.pickupConfirmationRequired => 'Pickup Confirmation Required',
    DeliveryStatus.productPickedUp => 'Product Picked Up',
    DeliveryStatus.goingToBuyer => 'Going to Buyer',
    DeliveryStatus.arrivedAtDelivery => 'Arrived at Delivery',
    DeliveryStatus.waitingForBuyer => 'Waiting for Buyer',
    DeliveryStatus.deliveryConfirmationRequired =>
      'Delivery Confirmation Required',
    DeliveryStatus.productDelivered => 'Product Delivered',
    DeliveryStatus.deliveryCompleted => 'Delivery Completed',
    DeliveryStatus.cancelled => 'Cancelled',
    DeliveryStatus.failed => 'Failed',
    DeliveryStatus.returned => 'Returned',
    DeliveryStatus.reassigned => 'Reassigned',
    DeliveryStatus.disputed => 'Disputed',
  };

  IconData get icon => switch (this) {
    DeliveryStatus.pending => Icons.schedule_outlined,
    DeliveryStatus.available => Icons.local_shipping_outlined,
    DeliveryStatus.reserved || DeliveryStatus.accepted => Icons.bookmark,
    DeliveryStatus.goingToPickup ||
    DeliveryStatus.goingToBuyer => Icons.route_outlined,
    DeliveryStatus.arrivedAtPickup ||
    DeliveryStatus.arrivedAtDelivery => Icons.location_on_outlined,
    DeliveryStatus.waitingForProduct ||
    DeliveryStatus.waitingForBuyer => Icons.schedule_outlined,
    DeliveryStatus.pickupConfirmationRequired ||
    DeliveryStatus.deliveryConfirmationRequired => Icons.verified_outlined,
    DeliveryStatus.productPickedUp => Icons.inventory_2_outlined,
    DeliveryStatus.productDelivered ||
    DeliveryStatus.deliveryCompleted => Icons.task_alt_outlined,
    DeliveryStatus.cancelled || DeliveryStatus.failed => Icons.cancel_outlined,
    DeliveryStatus.returned => Icons.keyboard_return_outlined,
    DeliveryStatus.reassigned => Icons.swap_horiz_outlined,
    DeliveryStatus.disputed => Icons.report_problem_outlined,
  };
}
