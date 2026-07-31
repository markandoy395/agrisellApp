import 'package:agresell_app/features/rider/deliveries/domain/delivery_proof.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';

enum DeliveryStage {
  readyForPickup,
  accepted,
  goingToPickup,
  arrivedAtPickup,
  pickedUp,
  goingToDelivery,
  arrivedAtDelivery,
  delivered,
  completed,
  cancelled,
  failed,
}

extension DeliveryStageDetails on DeliveryStage {
  String get label {
    return switch (this) {
      DeliveryStage.readyForPickup => 'Ready for Pickup',
      DeliveryStage.accepted => 'Delivery Accepted',
      DeliveryStage.goingToPickup => 'Going to Pickup Location',
      DeliveryStage.arrivedAtPickup => 'Arrived at Pickup Location',
      DeliveryStage.pickedUp => 'Product Picked Up',
      DeliveryStage.goingToDelivery => 'Going to Delivery Location',
      DeliveryStage.arrivedAtDelivery => 'Arrived at Delivery Location',
      DeliveryStage.delivered => 'Product Delivered',
      DeliveryStage.completed => 'Delivery Completed',
      DeliveryStage.cancelled => 'Cancelled',
      DeliveryStage.failed => 'Failed',
    };
  }

  DeliveryStage? get next {
    return switch (this) {
      DeliveryStage.readyForPickup => DeliveryStage.accepted,
      DeliveryStage.accepted => DeliveryStage.goingToPickup,
      DeliveryStage.goingToPickup => DeliveryStage.arrivedAtPickup,
      DeliveryStage.arrivedAtPickup => DeliveryStage.pickedUp,
      DeliveryStage.pickedUp => DeliveryStage.goingToDelivery,
      DeliveryStage.goingToDelivery => DeliveryStage.arrivedAtDelivery,
      DeliveryStage.arrivedAtDelivery => DeliveryStage.delivered,
      DeliveryStage.delivered => DeliveryStage.completed,
      DeliveryStage.completed ||
      DeliveryStage.cancelled ||
      DeliveryStage.failed => null,
    };
  }

  DeliveryProofPurpose? get requiredProofPurpose {
    return switch (this) {
      DeliveryStage.pickedUp => DeliveryProofPurpose.pickup,
      DeliveryStage.completed => DeliveryProofPurpose.completion,
      _ => null,
    };
  }

  bool get isTerminal {
    return this == DeliveryStage.completed ||
        this == DeliveryStage.cancelled ||
        this == DeliveryStage.failed;
  }

  bool get isDeliveryLeg {
    return switch (this) {
      DeliveryStage.pickedUp ||
      DeliveryStage.goingToDelivery ||
      DeliveryStage.arrivedAtDelivery ||
      DeliveryStage.delivered => true,
      _ => false,
    };
  }
}

/// Temporary adapter for screens that still use the Phase 0 delivery stages.
extension LegacyDeliveryStageAdapter on DeliveryStage {
  DeliveryStatus get canonicalStatus => switch (this) {
    DeliveryStage.readyForPickup => DeliveryStatus.available,
    DeliveryStage.accepted => DeliveryStatus.accepted,
    DeliveryStage.goingToPickup => DeliveryStatus.goingToPickup,
    DeliveryStage.arrivedAtPickup => DeliveryStatus.arrivedAtPickup,
    DeliveryStage.pickedUp => DeliveryStatus.productPickedUp,
    DeliveryStage.goingToDelivery => DeliveryStatus.goingToBuyer,
    DeliveryStage.arrivedAtDelivery => DeliveryStatus.arrivedAtDelivery,
    DeliveryStage.delivered => DeliveryStatus.productDelivered,
    DeliveryStage.completed => DeliveryStatus.deliveryCompleted,
    DeliveryStage.cancelled => DeliveryStatus.cancelled,
    DeliveryStage.failed => DeliveryStatus.failed,
  };
}

DeliveryStage legacyStageForDeliveryStatus(DeliveryStatus status) {
  return switch (status) {
    DeliveryStatus.pending => DeliveryStage.readyForPickup,
    DeliveryStatus.available => DeliveryStage.readyForPickup,
    DeliveryStatus.reserved ||
    DeliveryStatus.accepted => DeliveryStage.accepted,
    DeliveryStatus.goingToPickup => DeliveryStage.goingToPickup,
    DeliveryStatus.arrivedAtPickup ||
    DeliveryStatus.waitingForProduct ||
    DeliveryStatus.pickupConfirmationRequired => DeliveryStage.arrivedAtPickup,
    DeliveryStatus.productPickedUp => DeliveryStage.pickedUp,
    DeliveryStatus.goingToBuyer => DeliveryStage.goingToDelivery,
    DeliveryStatus.arrivedAtDelivery ||
    DeliveryStatus.waitingForBuyer ||
    DeliveryStatus.deliveryConfirmationRequired =>
      DeliveryStage.arrivedAtDelivery,
    DeliveryStatus.productDelivered => DeliveryStage.delivered,
    DeliveryStatus.deliveryCompleted => DeliveryStage.completed,
    DeliveryStatus.cancelled => DeliveryStage.cancelled,
    DeliveryStatus.failed ||
    DeliveryStatus.returned ||
    DeliveryStatus.reassigned ||
    DeliveryStatus.disputed => DeliveryStage.failed,
  };
}
