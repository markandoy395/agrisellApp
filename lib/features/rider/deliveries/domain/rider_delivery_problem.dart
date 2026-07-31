import 'delivery_status_update.dart';

enum RiderDeliveryProblemKind {
  productNotReady,
  wrongProduct,
  incorrectQuantity,
  incorrectWeight,
  damagedProduct,
  farmerUnavailable,
  buyerUnavailable,
  wrongAddress,
  routeBlocked,
  confirmationCodeIssue,
  paymentIssue,
  appIssue,
  mapIssue,
  other,
}

enum RiderDeliveryProblemStatus {
  submitted,
  underReview,
  waitingForInformation,
  resolved,
  rejected,
  escalated,
}

extension RiderDeliveryProblemKindDetails on RiderDeliveryProblemKind {
  String get label => switch (this) {
    RiderDeliveryProblemKind.productNotReady => 'Product not ready',
    RiderDeliveryProblemKind.wrongProduct => 'Wrong product',
    RiderDeliveryProblemKind.incorrectQuantity => 'Incorrect quantity',
    RiderDeliveryProblemKind.incorrectWeight => 'Incorrect weight',
    RiderDeliveryProblemKind.damagedProduct => 'Damaged product',
    RiderDeliveryProblemKind.farmerUnavailable => 'Farmer unavailable',
    RiderDeliveryProblemKind.buyerUnavailable => 'Buyer unavailable',
    RiderDeliveryProblemKind.wrongAddress => 'Wrong address',
    RiderDeliveryProblemKind.routeBlocked => 'Route blocked',
    RiderDeliveryProblemKind.confirmationCodeIssue => 'Confirmation-code issue',
    RiderDeliveryProblemKind.paymentIssue => 'Payment issue',
    RiderDeliveryProblemKind.appIssue => 'App issue',
    RiderDeliveryProblemKind.mapIssue => 'Map issue',
    RiderDeliveryProblemKind.other => 'Other',
  };
}

extension RiderDeliveryProblemStatusDetails on RiderDeliveryProblemStatus {
  String get label => switch (this) {
    RiderDeliveryProblemStatus.submitted => 'Submitted',
    RiderDeliveryProblemStatus.underReview => 'Under review',
    RiderDeliveryProblemStatus.waitingForInformation =>
      'Waiting for information',
    RiderDeliveryProblemStatus.resolved => 'Resolved',
    RiderDeliveryProblemStatus.rejected => 'Rejected',
    RiderDeliveryProblemStatus.escalated => 'Escalated',
  };
}

class RiderDeliveryProblemReport {
  const RiderDeliveryProblemReport({
    required this.id,
    required this.deliveryId,
    required this.riderId,
    required this.kind,
    required this.location,
    required this.createdAt,
    required this.notes,
    this.photoReferences = const [],
    this.status = RiderDeliveryProblemStatus.submitted,
  });

  final String id;
  final String deliveryId;
  final String riderId;
  final RiderDeliveryProblemKind kind;
  final DeliveryStatusLocation location;
  final DateTime createdAt;
  final String notes;
  final List<String> photoReferences;
  final RiderDeliveryProblemStatus status;

  RiderDeliveryProblemReport copyWith({RiderDeliveryProblemStatus? status}) =>
      RiderDeliveryProblemReport(
        id: id,
        deliveryId: deliveryId,
        riderId: riderId,
        kind: kind,
        location: location,
        createdAt: createdAt,
        notes: notes,
        photoReferences: photoReferences,
        status: status ?? this.status,
      );
}
