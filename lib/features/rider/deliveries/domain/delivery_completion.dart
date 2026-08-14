import 'package:crypto/crypto.dart';

import 'delivery_request.dart';
import 'delivery_earning.dart';
import 'delivery_payment.dart';
import 'delivery_status_event.dart';
import 'delivery_status_update.dart';

enum DeliveryConfirmationMethod {
  confirmationCode,
  qrCode,
  buyerConfirmation,
  buyerSignature,
  handoverPhoto,
  recipientName,
  deliveryNotes,
  gpsLocation,
  timestamp,
}

extension DeliveryConfirmationMethodDetails on DeliveryConfirmationMethod {
  String get label => switch (this) {
    DeliveryConfirmationMethod.confirmationCode => 'Confirmation code',
    DeliveryConfirmationMethod.qrCode => 'QR code',
    DeliveryConfirmationMethod.buyerConfirmation => 'Buyer confirmation',
    DeliveryConfirmationMethod.buyerSignature => 'Buyer signature',
    DeliveryConfirmationMethod.handoverPhoto => 'Product handover photo',
    DeliveryConfirmationMethod.recipientName => 'Recipient name',
    DeliveryConfirmationMethod.deliveryNotes => 'Delivery notes',
    DeliveryConfirmationMethod.gpsLocation => 'GPS location',
    DeliveryConfirmationMethod.timestamp => 'Delivery timestamp',
  };
}

class DeliveryCompletionConfiguration {
  const DeliveryCompletionConfiguration({
    required this.requiredMethods,
    this.deliveryCodeHash,
    this.qrPayloadHash,
    this.codeExpiresAt,
    this.maxCodeAttempts = 3,
    this.maxAccuracyMeters = 50,
    this.maxLocationAge = const Duration(seconds: 45),
    this.finalEarning,
  });

  final Set<DeliveryConfirmationMethod> requiredMethods;
  final String? deliveryCodeHash;
  final String? qrPayloadHash;
  final DateTime? codeExpiresAt;
  final int maxCodeAttempts;
  final double maxAccuracyMeters;
  final Duration maxLocationAge;
  final DeliveryEarningBreakdown? finalEarning;

  static String hashSecret(String value) =>
      sha256.convert(value.trim().codeUnits).toString();
}

class DeliveryCompletionCommand {
  const DeliveryCompletionCommand({
    required this.deliveryId,
    required this.riderId,
    required this.idempotencyKey,
    required this.finalLocation,
    required this.proofReferences,
    this.evidenceCapturedAt,
    this.evidenceLocation,
    this.confirmationCode,
    this.qrPayload,
    this.recipientName,
    this.deliveryNotes,
    this.cashCollection,
  });

  final String deliveryId;
  final String riderId;
  final String idempotencyKey;
  final DeliveryStatusLocation finalLocation;
  final Map<DeliveryConfirmationMethod, String> proofReferences;
  final DateTime? evidenceCapturedAt;
  final DeliveryStatusLocation? evidenceLocation;
  final String? confirmationCode;
  final String? qrPayload;
  final String? recipientName;
  final String? deliveryNotes;
  final CashCollectionSubmission? cashCollection;
}

class DeliveryCompletionRecord {
  const DeliveryCompletionRecord({
    required this.request,
    required this.events,
    required this.completedAt,
    required this.finalLocation,
    required this.proofReferences,
    required this.buyerNotified,
    required this.farmerNotified,
    this.recipientName,
    this.deliveryNotes,
    this.earningStatus = DeliveryEarningStatus.pending,
    this.earning,
    this.cashCollection,
  });

  final DeliveryRequest request;
  final List<DeliveryStatusEvent> events;
  final DateTime completedAt;
  final DeliveryStatusLocation finalLocation;
  final Map<DeliveryConfirmationMethod, String> proofReferences;
  final bool buyerNotified;
  final bool farmerNotified;
  final String? recipientName;
  final String? deliveryNotes;
  final DeliveryEarningStatus earningStatus;
  final DeliveryEarningBreakdown? earning;
  final CashCollectionRecord? cashCollection;
}

class DeliveryCompletionResult {
  const DeliveryCompletionResult({required this.record});
  final DeliveryCompletionRecord record;
}

class DeliveryDestinationProblemReport {
  const DeliveryDestinationProblemReport({
    required this.id,
    required this.deliveryId,
    required this.riderId,
    required this.location,
    required this.reportedAt,
    required this.notes,
  });

  final String id;
  final String deliveryId;
  final String riderId;
  final DeliveryStatusLocation location;
  final DateTime reportedAt;
  final String notes;
}
