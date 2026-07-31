enum DeliveryWaitingLocation { pickup, destination }

class DeliveryWaitingTime {
  const DeliveryWaitingTime({
    required this.id,
    required this.deliveryId,
    required this.location,
    required this.startedAt,
    this.endedAt,
  });

  final String id;
  final String deliveryId;
  final DeliveryWaitingLocation location;
  final DateTime startedAt;
  final DateTime? endedAt;

  Duration get duration => (endedAt ?? DateTime.now()).difference(startedAt);
}

enum DeliveryProblemType {
  sellerUnavailable,
  buyerUnavailable,
  productIssue,
  addressIssue,
  vehicleIssue,
  safetyIssue,
  other,
}

class DeliveryProblem {
  const DeliveryProblem({
    required this.id,
    required this.deliveryId,
    required this.type,
    required this.description,
    required this.reportedAt,
    this.proofReference,
  });

  final String id;
  final String deliveryId;
  final DeliveryProblemType type;
  final String description;
  final DateTime reportedAt;
  final String? proofReference;
}

enum DeliveryCancellationReason {
  riderEmergency,
  vehicleIssue,
  unsafeConditions,
  sellerRequest,
  buyerRequest,
  duplicateAssignment,
  other,
}

class DeliveryCancellation {
  const DeliveryCancellation({
    required this.id,
    required this.deliveryId,
    required this.reason,
    required this.details,
    required this.cancelledAt,
    required this.cancelledBy,
  });

  final String id;
  final String deliveryId;
  final DeliveryCancellationReason reason;
  final String details;
  final DateTime cancelledAt;
  final String cancelledBy;
}

enum FailedDeliveryReason {
  recipientUnavailable,
  invalidAddress,
  rejectedByRecipient,
  damagedProduct,
  unsafeConditions,
  other,
}

class FailedDeliveryRecord {
  const FailedDeliveryRecord({
    required this.id,
    required this.deliveryId,
    required this.reason,
    required this.details,
    required this.recordedAt,
    this.proofReference,
    this.approvedResolutionReference,
  });

  final String id;
  final String deliveryId;
  final FailedDeliveryReason reason;
  final String details;
  final DateTime recordedAt;
  final String? proofReference;
  final String? approvedResolutionReference;
}
