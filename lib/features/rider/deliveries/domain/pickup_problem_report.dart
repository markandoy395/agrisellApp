import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_update.dart';

enum PickupProblemKind {
  productNotReady,
  wrongProduct,
  incorrectQuantity,
  incorrectWeight,
  damagedProduct,
  poorPackaging,
  exceedsVehicleCapacity,
  farmerUnavailable,
  confirmationProblem,
  other,
}

extension PickupProblemKindDetails on PickupProblemKind {
  String get label => switch (this) {
    PickupProblemKind.productNotReady => 'Product not ready',
    PickupProblemKind.wrongProduct => 'Wrong product',
    PickupProblemKind.incorrectQuantity => 'Incorrect quantity',
    PickupProblemKind.incorrectWeight => 'Incorrect weight',
    PickupProblemKind.damagedProduct => 'Damaged product',
    PickupProblemKind.poorPackaging => 'Poor packaging',
    PickupProblemKind.exceedsVehicleCapacity => 'Exceeds vehicle capacity',
    PickupProblemKind.farmerUnavailable => 'Farmer unavailable',
    PickupProblemKind.confirmationProblem => 'Confirmation problem',
    PickupProblemKind.other => 'Other',
  };
}

class PickupProblemReport {
  const PickupProblemReport({
    required this.id,
    required this.deliveryId,
    required this.riderId,
    required this.kind,
    required this.reportedAt,
    required this.location,
    required this.notes,
    this.photoReferences = const [],
  });

  final String id;
  final String deliveryId;
  final String riderId;
  final PickupProblemKind kind;
  final DateTime reportedAt;
  final DeliveryStatusLocation location;
  final String notes;
  final List<String> photoReferences;
}
