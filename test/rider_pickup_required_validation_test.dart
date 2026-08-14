import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_update.dart';
import 'package:agresell_app/features/rider/deliveries/domain/pickup_confirmation.dart';

void main() {
  test('all required pickup values, including zero weight, pass', () {
    expect(validatePickupCompletion(_command()).issues, isEmpty);
    expect(
      validatePickupCompletion(_command(checklist: _checklist(weight: 0)))
          .issues,
      isEmpty,
    );
  });

  test('unavailable, stale, approximate, and mocked GPS are blocked', () {
    for (final location in [
      _location(timestampProvided: false),
      _location(timestamp: DateTime.now().subtract(const Duration(minutes: 2))),
      _location(isApproximate: true),
      _location(isMocked: true),
    ]) {
      expect(
        validatePickupCompletion(_command(location: location)).issues,
        contains(PickupValidationIssue.location),
      );
    }
  });

  test('one unchecked checklist item blocks pickup', () {
    final result = validatePickupCompletion(
      _command(checklist: _checklist(fitsVehicle: false)),
    );
    expect(result.issues, [PickupValidationIssue.checklist]);
  });

  test('zero and negative quantities are blocked', () {
    for (final quantity in [0, -1]) {
      expect(
        validatePickupCompletion(
          _command(checklist: _checklist(quantity: quantity)),
        ).issues,
        [PickupValidationIssue.quantity],
      );
    }
  });

  test('negative and non-finite weights are blocked', () {
    for (final weight in [-1.0, double.nan, double.infinity]) {
      expect(
        validatePickupCompletion(
          _command(checklist: _checklist(weight: weight)),
        ).issues,
        [PickupValidationIssue.weight],
      );
    }
  });

  test('missing product photo is blocked', () {
    expect(validatePickupCompletion(_command(hasPhoto: false)).issues, [
      PickupValidationIssue.productPhoto,
    ]);
  });

  test(
    'all missing requirements are returned and completed ones are omitted',
    () {
      final result = validatePickupCompletion(
        _command(
          location: _location(timestampProvided: false),
          checklist: _checklist(fitsVehicle: false, quantity: 0, weight: -1),
          hasPhoto: false,
        ),
      );
      expect(result.issues, [
        PickupValidationIssue.location,
        PickupValidationIssue.checklist,
        PickupValidationIssue.quantity,
        PickupValidationIssue.weight,
        PickupValidationIssue.productPhoto,
      ]);
      expect(result.message, startsWith(PickupCompletionValidation.heading));
    },
  );
}

PickupCompletionCommand _command({
  DeliveryStatusLocation? location,
  PickupConditionChecklist? checklist,
  bool hasPhoto = true,
}) => PickupCompletionCommand(
  deliveryId: 'delivery-1',
  riderId: 'rider-1',
  idempotencyKey: 'pickup-key',
  location: location ?? _location(),
  checklist: checklist ?? _checklist(),
  proofReferences: {
    if (hasPhoto)
      PickupConfirmationMethod.productPhoto: 'protected://product-photo',
  },
);

DeliveryStatusLocation _location({
  DateTime? timestamp,
  bool timestampProvided = true,
  bool isMocked = false,
  bool isApproximate = false,
}) => DeliveryStatusLocation(
  latitude: 8.48,
  longitude: 124.65,
  accuracyMeters: 5,
  timestamp: timestampProvided ? (timestamp ?? DateTime.now()) : null,
  isMocked: isMocked,
  isApproximate: isApproximate,
);

PickupConditionChecklist _checklist({
  bool fitsVehicle = true,
  int quantity = 2,
  double weight = 10,
}) => PickupConditionChecklist(
  correctProduct: true,
  correctQuantity: true,
  correctWeight: true,
  securePackaging: true,
  notVisiblyDamaged: true,
  matchesRequest: true,
  fitsVehicle: fitsVehicle,
  handlingInstructionsReceived: true,
  confirmedQuantity: quantity,
  confirmedWeightKg: weight,
);
