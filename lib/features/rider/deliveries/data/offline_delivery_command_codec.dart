import '../domain/delivery_completion.dart';
import '../domain/delivery_payment.dart';
import '../domain/delivery_status.dart';
import '../domain/delivery_status_event.dart';
import '../domain/delivery_status_update.dart';
import '../domain/offline_delivery_action.dart';
import '../domain/pickup_confirmation.dart';

Map<String, Object?> encodeStatusCommand(DeliveryStatusUpdateCommand command) =>
    {
      'previousStatus': command.previousStatus.backendValue,
      'newStatus': command.newStatus.backendValue,
      'location': _encodeLocation(command.location),
      'manualArrivalOverride': command.manualArrivalOverride,
      'manualOverrideReason': command.manualOverrideReason,
      'manualOverrideNotes': command.manualOverrideNotes,
      'note': command.note,
      'reasonCode': command.reasonCode,
      'proofReference': command.proofReference,
    };

DeliveryStatusUpdateCommand decodeStatusCommand(OfflineDeliveryAction action) =>
    DeliveryStatusUpdateCommand(
      deliveryId: action.deliveryId,
      riderId: action.riderId,
      previousStatus: DeliveryStatus.fromBackendValue(
        action.payload['previousStatus'] as String,
      ),
      newStatus: DeliveryStatus.fromBackendValue(
        action.payload['newStatus'] as String,
      ),
      idempotencyKey: action.idempotencyKey,
      location: _decodeLocation(action.payload['location']),
      manualArrivalOverride:
          action.payload['manualArrivalOverride'] as bool? ?? false,
      manualOverrideReason: action.payload['manualOverrideReason'] as String?,
      manualOverrideNotes: action.payload['manualOverrideNotes'] as String?,
      note: action.payload['note'] as String?,
      reasonCode: action.payload['reasonCode'] as String?,
      proofReference: action.payload['proofReference'] as String?,
      source: DeliveryEventSource.offline,
    );

Map<String, Object?> encodePickupCommand(PickupCompletionCommand command) => {
  'location': _encodeLocation(command.location),
  'checklist': {
    'correctProduct': command.checklist.correctProduct,
    'correctQuantity': command.checklist.correctQuantity,
    'correctWeight': command.checklist.correctWeight,
    'securePackaging': command.checklist.securePackaging,
    'notVisiblyDamaged': command.checklist.notVisiblyDamaged,
    'matchesRequest': command.checklist.matchesRequest,
    'fitsVehicle': command.checklist.fitsVehicle,
    'handlingInstructionsReceived':
        command.checklist.handlingInstructionsReceived,
    'confirmedQuantity': command.checklist.confirmedQuantity,
    'confirmedWeightKg': command.checklist.confirmedWeightKg,
  },
  'proofReferences': command.proofReferences.map(
    (key, value) => MapEntry(key.name, value),
  ),
  'confirmationCode': command.confirmationCode,
  'qrPayload': command.qrPayload,
};

PickupCompletionCommand decodePickupCommand(OfflineDeliveryAction action) {
  final checklist = Map<String, Object?>.from(
    action.payload['checklist'] as Map,
  );
  final proofs = Map<String, Object?>.from(
    action.payload['proofReferences'] as Map,
  );
  return PickupCompletionCommand(
    deliveryId: action.deliveryId,
    riderId: action.riderId,
    idempotencyKey: action.idempotencyKey,
    location: _decodeLocation(action.payload['location'])!,
    checklist: PickupConditionChecklist(
      correctProduct: checklist['correctProduct'] as bool,
      correctQuantity: checklist['correctQuantity'] as bool,
      correctWeight: checklist['correctWeight'] as bool,
      securePackaging: checklist['securePackaging'] as bool,
      notVisiblyDamaged: checklist['notVisiblyDamaged'] as bool,
      matchesRequest: checklist['matchesRequest'] as bool,
      fitsVehicle: checklist['fitsVehicle'] as bool,
      handlingInstructionsReceived:
          checklist['handlingInstructionsReceived'] as bool,
      confirmedQuantity: (checklist['confirmedQuantity'] as num).toInt(),
      confirmedWeightKg: (checklist['confirmedWeightKg'] as num).toDouble(),
    ),
    proofReferences: proofs.map(
      (key, value) => MapEntry(
        PickupConfirmationMethod.values.byName(key),
        value as String,
      ),
    ),
    confirmationCode: action.payload['confirmationCode'] as String?,
    qrPayload: action.payload['qrPayload'] as String?,
  );
}

Map<String, Object?> encodeDeliveryCommand(
  DeliveryCompletionCommand command,
) => {
  'finalLocation': _encodeLocation(command.finalLocation),
  'proofReferences': command.proofReferences.map(
    (key, value) => MapEntry(key.name, value),
  ),
  'evidenceCapturedAt': command.evidenceCapturedAt?.toUtc().toIso8601String(),
  'evidenceLocation': _encodeLocation(command.evidenceLocation),
  'confirmationCode': command.confirmationCode,
  'qrPayload': command.qrPayload,
  'recipientName': command.recipientName,
  'deliveryNotes': command.deliveryNotes,
  'cashCollection': command.cashCollection == null
      ? null
      : {
          'amountReceived': command.cashCollection!.amountReceived,
          'collectionConfirmed': command.cashCollection!.collectionConfirmed,
          'issue': command.cashCollection!.issue?.name,
          'notes': command.cashCollection!.notes,
        },
};

DeliveryCompletionCommand decodeDeliveryCommand(OfflineDeliveryAction action) {
  final proofs = Map<String, Object?>.from(
    action.payload['proofReferences'] as Map,
  );
  final cashValue = action.payload['cashCollection'];
  final cash = cashValue == null
      ? null
      : Map<String, Object?>.from(cashValue as Map);
  return DeliveryCompletionCommand(
    deliveryId: action.deliveryId,
    riderId: action.riderId,
    idempotencyKey: action.idempotencyKey,
    finalLocation: _decodeLocation(action.payload['finalLocation'])!,
    proofReferences: proofs.map(
      (key, value) => MapEntry(
        DeliveryConfirmationMethod.values.byName(key),
        value as String,
      ),
    ),
    evidenceCapturedAt: DateTime.tryParse(
      action.payload['evidenceCapturedAt'] as String? ?? '',
    )?.toLocal(),
    evidenceLocation: _decodeLocation(action.payload['evidenceLocation']),
    confirmationCode: action.payload['confirmationCode'] as String?,
    qrPayload: action.payload['qrPayload'] as String?,
    recipientName: action.payload['recipientName'] as String?,
    deliveryNotes: action.payload['deliveryNotes'] as String?,
    cashCollection: cash == null
        ? null
        : CashCollectionSubmission(
            amountReceived: (cash['amountReceived'] as num).toDouble(),
            collectionConfirmed: cash['collectionConfirmed'] as bool,
            issue: cash['issue'] == null
                ? null
                : CashCollectionIssue.values.byName(cash['issue'] as String),
            notes: cash['notes'] as String?,
          ),
  );
}

Map<String, Object?>? _encodeLocation(DeliveryStatusLocation? location) =>
    location == null
    ? null
    : {
        'latitude': location.latitude,
        'longitude': location.longitude,
        'accuracyMeters': location.accuracyMeters,
        'timestamp': location.timestamp?.toUtc().toIso8601String(),
        'altitudeMeters': location.altitudeMeters,
        'speedMetersPerSecond': location.speedMetersPerSecond,
        'headingDegrees': location.headingDegrees,
        'isMocked': location.isMocked,
        'isApproximate': location.isApproximate,
      };

DeliveryStatusLocation? _decodeLocation(Object? value) {
  if (value == null) return null;
  final json = Map<String, Object?>.from(value as Map);
  final timestamp = json['timestamp'] as String?;
  return DeliveryStatusLocation(
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    accuracyMeters: (json['accuracyMeters'] as num).toDouble(),
    timestamp: timestamp == null ? null : DateTime.parse(timestamp).toLocal(),
    altitudeMeters: (json['altitudeMeters'] as num?)?.toDouble(),
    speedMetersPerSecond:
        (json['speedMetersPerSecond'] as num?)?.toDouble() ?? 0,
    headingDegrees: (json['headingDegrees'] as num?)?.toDouble() ?? 0,
    isMocked: json['isMocked'] as bool? ?? false,
    isApproximate: json['isApproximate'] as bool? ?? false,
  );
}
