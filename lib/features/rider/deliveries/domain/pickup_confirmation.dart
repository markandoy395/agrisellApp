import 'package:crypto/crypto.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_update.dart';

enum PickupConfirmationMethod {
  confirmationCode,
  qrCode,
  farmerConfirmation,
  productPhoto,
  packagePhoto,
  quantityConfirmation,
  weightConfirmation,
  farmerSignature,
}

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

class PickupConfiguration {
  const PickupConfiguration({
    required this.requiredMethods,
    this.pickupCodeHash,
    this.qrPayloadHash,
    this.codeExpiresAt,
    this.maxCodeAttempts = 3,
    this.arrivalRadiusMeters = 120,
    this.maxArrivalAccuracyMeters = 50,
  });

  final Set<PickupConfirmationMethod> requiredMethods;
  final String? pickupCodeHash;
  final String? qrPayloadHash;
  final DateTime? codeExpiresAt;
  final int maxCodeAttempts;
  final double arrivalRadiusMeters;
  final double maxArrivalAccuracyMeters;

  static String hashCodeValue(String value) =>
      sha256.convert(value.trim().codeUnits).toString();

  static String hashQrPayload(String value) => hashCodeValue(value);
}

class PickupConditionChecklist {
  const PickupConditionChecklist({
    required this.correctProduct,
    required this.correctQuantity,
    required this.correctWeight,
    required this.securePackaging,
    required this.notVisiblyDamaged,
    required this.matchesRequest,
    required this.fitsVehicle,
    required this.handlingInstructionsReceived,
    required this.confirmedQuantity,
    required this.confirmedWeightKg,
  });

  final bool correctProduct;
  final bool correctQuantity;
  final bool correctWeight;
  final bool securePackaging;
  final bool notVisiblyDamaged;
  final bool matchesRequest;
  final bool fitsVehicle;
  final bool handlingInstructionsReceived;
  final int confirmedQuantity;
  final double confirmedWeightKg;

  bool get allItemsChecked =>
      correctProduct &&
      correctQuantity &&
      correctWeight &&
      securePackaging &&
      notVisiblyDamaged &&
      matchesRequest &&
      fitsVehicle &&
      handlingInstructionsReceived;

  bool get hasValidQuantity => confirmedQuantity > 0;
  bool get hasValidWeight =>
      confirmedWeightKg.isFinite && confirmedWeightKg >= 0;
  bool get passes => allItemsChecked && hasValidQuantity && hasValidWeight;
}

enum PickupValidationIssue {
  location,
  checklist,
  quantity,
  weight,
  productPhoto,
}

extension PickupValidationIssueDetails on PickupValidationIssue {
  String get message => switch (this) {
    PickupValidationIssue.location =>
      'Pickup location is unavailable. Please enable Precise Location and try again.',
    PickupValidationIssue.checklist =>
      'Complete all 8 product condition checklist items.',
    PickupValidationIssue.quantity => 'Enter a quantity greater than 0.',
    PickupValidationIssue.weight => 'Enter a valid weight of 0 kg or greater.',
    PickupValidationIssue.productPhoto => 'Upload the required product photo.',
  };
}

class PickupCompletionValidation {
  const PickupCompletionValidation(this.issues);

  static const heading =
      'Pickup cannot be confirmed because one or more required requirements are incomplete.';

  final List<PickupValidationIssue> issues;
  bool get isValid => issues.isEmpty;

  String get message =>
      [heading, ...issues.map((item) => item.message)].join('\n');
}

PickupCompletionValidation validatePickupCompletion(
  PickupCompletionCommand command, {
  DateTime? now,
}) {
  final checklist = command.checklist;
  return PickupCompletionValidation([
    if (!command.location.isUsableForPickup(now: now))
      PickupValidationIssue.location,
    if (!checklist.allItemsChecked) PickupValidationIssue.checklist,
    if (!checklist.hasValidQuantity) PickupValidationIssue.quantity,
    if (!checklist.hasValidWeight) PickupValidationIssue.weight,
    if ((command.proofReferences[PickupConfirmationMethod.productPhoto]
            ?.trim()
            .isEmpty ??
        true))
      PickupValidationIssue.productPhoto,
  ]);
}

class PickupCompletionCommand {
  const PickupCompletionCommand({
    required this.deliveryId,
    required this.riderId,
    required this.idempotencyKey,
    required this.location,
    required this.checklist,
    required this.proofReferences,
    this.confirmationCode,
    this.qrPayload,
  });

  final String deliveryId;
  final String riderId;
  final String idempotencyKey;
  final DeliveryStatusLocation location;
  final PickupConditionChecklist checklist;
  final Map<PickupConfirmationMethod, String> proofReferences;
  final String? confirmationCode;
  final String? qrPayload;
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

class PickupCompletionResult {
  const PickupCompletionResult({
    required this.status,
    required this.proofReferences,
    required this.buyerNotified,
    this.record,
  });

  final DeliveryStatusSnapshot status;
  final List<String> proofReferences;
  final bool buyerNotified;
  final PickupCompletionRecord? record;
}

class PickupCompletionRecord {
  const PickupCompletionRecord({
    required this.deliveryId,
    required this.riderId,
    required this.recordedAt,
    required this.location,
    required this.checklist,
    required this.proofReferences,
    required this.buyerNotified,
  });

  final String deliveryId;
  final String riderId;
  final DateTime recordedAt;
  final DeliveryStatusLocation location;
  final PickupConditionChecklist checklist;
  final Map<PickupConfirmationMethod, String> proofReferences;
  final bool buyerNotified;
}
