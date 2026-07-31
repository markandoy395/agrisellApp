enum DeliveryOutcomeType { cancelled, failed }

class DeliveryOutcome {
  const DeliveryOutcome({
    required this.type,
    required this.reason,
    required this.recordedAt,
  }) : assert(reason.length > 0);

  final DeliveryOutcomeType type;
  final String reason;
  final DateTime recordedAt;
}
