enum RiderDatabaseAvailability { offline, online, busy }

enum RiderDeliveryProgress {
  waiting,
  assigned,
  goingToPickup,
  arrivedAtPickup,
  pickedUp,
  goingToBuyer,
  arrivedAtDelivery,
  completed;

  String get databaseValue => switch (this) {
    goingToPickup => 'going_to_pickup',
    arrivedAtPickup => 'arrived_at_pickup',
    goingToBuyer => 'going_to_delivery',
    arrivedAtDelivery => 'arrived_at_delivery',
    _ => name,
  };

  static RiderDeliveryProgress parse(Object? value) => values.firstWhere(
    (item) =>
        item.databaseValue == value?.toString() ||
        (item == goingToBuyer && value?.toString() == 'going_to_buyer'),
    orElse: () => waiting,
  );
}
