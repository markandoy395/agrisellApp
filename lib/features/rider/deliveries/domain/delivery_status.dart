enum DeliveryStatus {
  pending('pending'),
  available('available'),
  reserved('reserved'),
  accepted('accepted'),
  goingToPickup('going_to_pickup'),
  arrivedAtPickup('arrived_at_pickup'),
  waitingForProduct('waiting_for_product'),
  pickupConfirmationRequired('pickup_confirmation_required'),
  productPickedUp('product_picked_up'),
  goingToBuyer('going_to_buyer'),
  arrivedAtDelivery('arrived_at_delivery'),
  waitingForBuyer('waiting_for_buyer'),
  deliveryConfirmationRequired('delivery_confirmation_required'),
  productDelivered('product_delivered'),
  deliveryCompleted('delivery_completed'),
  cancelled('cancelled'),
  failed('failed'),
  returned('returned'),
  reassigned('reassigned'),
  disputed('disputed');

  const DeliveryStatus(this.backendValue);

  final String backendValue;

  static DeliveryStatus fromBackendValue(String value) {
    final normalized = _normalize(value);
    return switch (normalized) {
      'ready_for_pickup' => available,
      'picked_up' => productPickedUp,
      'going_to_delivery' => goingToBuyer,
      'delivered' => productDelivered,
      'completed' => deliveryCompleted,
      _ => values.firstWhere(
        (status) => status.backendValue == normalized,
        orElse: () =>
            throw FormatException('Unknown delivery status value: $value'),
      ),
    };
  }

  static String _normalize(String value) {
    final snakeCase = value.trim().replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'),
      (match) => '${match.group(1)}_${match.group(2)}',
    );
    return snakeCase.replaceAll('-', '_').toLowerCase();
  }
}

extension DeliveryStatusRules on DeliveryStatus {
  bool get isNormalFlow => index <= DeliveryStatus.deliveryCompleted.index;

  bool get isTerminal => switch (this) {
    DeliveryStatus.deliveryCompleted ||
    DeliveryStatus.cancelled ||
    DeliveryStatus.failed ||
    DeliveryStatus.returned => true,
    _ => false,
  };

  bool get isSpecialResolution => switch (this) {
    DeliveryStatus.cancelled ||
    DeliveryStatus.failed ||
    DeliveryStatus.returned ||
    DeliveryStatus.reassigned ||
    DeliveryStatus.disputed => true,
    _ => false,
  };
}

extension DeliveryStatusDatabaseValue on DeliveryStatus {
  String get databaseValue => switch (this) {
    DeliveryStatus.pending => 'pending',
    DeliveryStatus.available || DeliveryStatus.reserved => 'available',
    DeliveryStatus.accepted => 'accepted',
    DeliveryStatus.goingToPickup => 'going_to_pickup',
    DeliveryStatus.arrivedAtPickup ||
    DeliveryStatus.waitingForProduct ||
    DeliveryStatus.pickupConfirmationRequired => 'arrived_at_pickup',
    DeliveryStatus.productPickedUp => 'picked_up',
    DeliveryStatus.goingToBuyer => 'going_to_delivery',
    DeliveryStatus.arrivedAtDelivery ||
    DeliveryStatus.waitingForBuyer ||
    DeliveryStatus.deliveryConfirmationRequired => 'arrived_at_delivery',
    DeliveryStatus.productDelivered ||
    DeliveryStatus.deliveryCompleted => 'completed',
    DeliveryStatus.cancelled => 'cancelled',
    DeliveryStatus.failed ||
    DeliveryStatus.returned ||
    DeliveryStatus.reassigned ||
    DeliveryStatus.disputed => 'failed',
  };
}
