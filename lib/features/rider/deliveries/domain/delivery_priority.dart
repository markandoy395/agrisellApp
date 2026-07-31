enum DeliveryPriority {
  normal('normal'),
  urgent('urgent'),
  high('high'),
  standard('normal'),
  scheduled('normal'),
  priority('high'),
  sameDay('high');

  const DeliveryPriority(this.backendValue);

  final String backendValue;

  static DeliveryPriority fromBackendValue(Object? value) =>
      switch (value?.toString().trim().toLowerCase()) {
        'urgent' => DeliveryPriority.urgent,
        'high' || 'priority' || 'same_day' => DeliveryPriority.high,
        _ => DeliveryPriority.normal,
      };
}

extension DeliveryPriorityDetails on DeliveryPriority {
  int get rank => switch (this) {
    DeliveryPriority.normal || DeliveryPriority.standard => 0,
    DeliveryPriority.scheduled => 1,
    DeliveryPriority.high || DeliveryPriority.priority => 2,
    DeliveryPriority.sameDay => 3,
    DeliveryPriority.urgent => 4,
  };
}
