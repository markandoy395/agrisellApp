import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';

extension RiderAvailabilityPresentation on RiderAvailability {
  String get displayLabel => switch (this) {
    RiderAvailability.offline => 'Offline',
    RiderAvailability.onlineAvailable => 'Online and Available',
    RiderAvailability.reviewingDeliveryRequest => 'Reviewing Request',
    RiderAvailability.deliveryReserved => 'Delivery Reserved',
    RiderAvailability.goingToPickup => 'Going to Pickup',
    RiderAvailability.waitingAtPickup => 'Waiting at Pickup',
    RiderAvailability.productPickedUp => 'Product Picked Up',
    RiderAvailability.goingToBuyer => 'Going to Buyer',
    RiderAvailability.waitingAtDeliveryLocation => 'Waiting at Delivery',
    RiderAvailability.onBreak => 'On Break',
    RiderAvailability.temporarilyUnavailable => 'Temporarily Unavailable',
    RiderAvailability.emergency => 'Emergency',
  };

  IconData get icon => switch (this) {
    RiderAvailability.offline => Icons.cloud_off_outlined,
    RiderAvailability.onlineAvailable => Icons.check_circle_outline,
    RiderAvailability.reviewingDeliveryRequest => Icons.assignment_outlined,
    RiderAvailability.deliveryReserved => Icons.bookmark_outline,
    RiderAvailability.goingToPickup => Icons.route_outlined,
    RiderAvailability.waitingAtPickup => Icons.storefront_outlined,
    RiderAvailability.productPickedUp => Icons.inventory_2_outlined,
    RiderAvailability.goingToBuyer => Icons.delivery_dining_outlined,
    RiderAvailability.waitingAtDeliveryLocation => Icons.location_on_outlined,
    RiderAvailability.onBreak => Icons.free_breakfast_outlined,
    RiderAvailability.temporarilyUnavailable => Icons.pause_circle_outline,
    RiderAvailability.emergency => Icons.emergency_outlined,
  };
}
