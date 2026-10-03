enum PlacedOrderStatus {
  toPay,
  toShip,
  preparing,
  readyForPickup,
  shipping,
  delivered,
  cancelled,
}

extension PlacedOrderStatusLabel on PlacedOrderStatus {
  String get label {
    return switch (this) {
      PlacedOrderStatus.toPay => 'To Pay',
      PlacedOrderStatus.toShip => 'Awaiting farmer acceptance',
      PlacedOrderStatus.preparing => 'Farmer is preparing your order',
      PlacedOrderStatus.readyForPickup => 'Ready for rider pickup',
      PlacedOrderStatus.shipping => 'Shipping',
      PlacedOrderStatus.delivered => 'Completed',
      PlacedOrderStatus.cancelled => 'Cancelled',
    };
  }

  bool get canCancel {
    return switch (this) {
      PlacedOrderStatus.toPay || PlacedOrderStatus.toShip => true,
      PlacedOrderStatus.preparing ||
      PlacedOrderStatus.readyForPickup ||
      PlacedOrderStatus.shipping ||
      PlacedOrderStatus.delivered ||
      PlacedOrderStatus.cancelled => false,
    };
  }

  bool get canFarmerCancel {
    return switch (this) {
      PlacedOrderStatus.toPay ||
      PlacedOrderStatus.toShip ||
      PlacedOrderStatus.preparing ||
      PlacedOrderStatus.readyForPickup => true,
      PlacedOrderStatus.shipping ||
      PlacedOrderStatus.delivered ||
      PlacedOrderStatus.cancelled => false,
    };
  }

  bool get canLeaveFeedback {
    return this == PlacedOrderStatus.delivered;
  }
}
