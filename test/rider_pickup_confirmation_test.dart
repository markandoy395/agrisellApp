import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/data/pickup_proof_storage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_errors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_update.dart';
import 'package:agresell_app/features/rider/deliveries/domain/pickup_confirmation.dart';

void main() {
  test(
    'correct pickup code and required checks complete pickup once',
    () async {
      final repository = _repository();
      await _reachPickupConfirmation(repository);
      final command = _command(code: '246810');
      final first = await repository.completePickup(command);
      final replay = await repository.completePickup(command);
      expect(first.status.currentStatus, DeliveryStatus.productPickedUp);
      expect(first.status.request.proofs, isNotEmpty);
      expect(first.buyerNotified, isTrue);
      expect(replay.status.events, hasLength(first.status.events.length));
      await expectLater(
        repository.completePickup(_command(code: '246810', key: 'used-code')),
        throwsA(isA<DeliveryDomainException>()),
      );
    },
  );
  test(
    'incorrect, expired, and missing proof pickup submissions are rejected',
    () async {
      final repository = _repository();
      await _reachPickupConfirmation(repository);
      await expectLater(
        repository.completePickup(_command(code: '000000')),
        throwsA(isA<DeliveryDomainException>()),
      );
      final expired = _repository(expiresAt: DateTime(2020));
      await _reachPickupConfirmation(expired);
      await expectLater(
        expired.completePickup(_command(code: '246810')),
        throwsA(isA<DeliveryDomainException>()),
      );
      final photoRequired = _repository(
        methods: {PickupConfirmationMethod.productPhoto},
      );
      await _reachPickupConfirmation(photoRequired);
      await expectLater(
        photoRequired.completePickup(_command(code: null, proofs: {})),
        throwsA(isA<DeliveryDomainException>()),
      );
    },
  );
  test(
    'condition, capacity, and farmer-unavailable problems preserve active pickup',
    () async {
      final repository = _repository();
      await _reachPickupConfirmation(repository);
      await expectLater(
        repository.completePickup(
          _command(condition: _condition(fitsVehicle: false)),
        ),
        throwsA(isA<DeliveryDomainException>()),
      );
      final report = await repository.reportPickupProblem(
        PickupProblemReport(
          id: 'problem-1',
          deliveryId: 'delivery-1',
          riderId: 'rider-a',
          kind: PickupProblemKind.farmerUnavailable,
          reportedAt: DateTime(2030),
          location: _location,
          notes: 'Farmer unavailable.',
        ),
      );
      expect(report.kind, PickupProblemKind.farmerUnavailable);
      final completed = await repository.completePickup(_command());
      expect(completed.status.currentStatus, DeliveryStatus.productPickedUp);
    },
  );
  test('manual arrival override records valid GPS exception context', () async {
    final repository = _repository();
    await repository.updateDeliveryStatus(
      _status(DeliveryStatus.accepted, DeliveryStatus.goingToPickup),
    );
    final arrived = await repository.updateDeliveryStatus(
      DeliveryStatusUpdateCommand(
        deliveryId: 'delivery-1',
        riderId: 'rider-a',
        previousStatus: DeliveryStatus.goingToPickup,
        newStatus: DeliveryStatus.arrivedAtPickup,
        idempotencyKey: 'override',
        location: DeliveryStatusLocation(
          latitude: 8.7,
          longitude: 124.9,
          accuracyMeters: 80,
          timestamp: DateTime.now(),
        ),
        manualArrivalOverride: true,
        manualOverrideReason: 'location_inaccurate',
      ),
    );
    expect(arrived.events.last.reasonCode, 'location_inaccurate');
    expect(arrived.events.last.locationTimestamp, isNotNull);
    expect(arrived.events.last.isManualArrivalOverride, isTrue);
  });
  test('protected proof storage reports an upload failure', () async {
    final storage = PickupProofStorage(failUploads: true);
    await expectLater(
      storage.saveAttestation(
        deliveryId: 'delivery-1',
        method: PickupConfirmationMethod.farmerSignature,
      ),
      throwsA(isA<PickupProofStorageException>()),
    );
  });
}

final _location = DeliveryStatusLocation(
  latitude: 8.48,
  longitude: 124.65,
  accuracyMeters: 5,
  timestamp: DateTime.now(),
);
InMemoryRiderDeliveryRepository _repository({
  Set<PickupConfirmationMethod>? methods,
  DateTime? expiresAt,
}) => InMemoryRiderDeliveryRepository(
  requests: [_request()],
  pickupConfigurations: {
    'delivery-1': PickupConfiguration(
      requiredMethods:
          methods ??
          {
            PickupConfirmationMethod.confirmationCode,
            PickupConfirmationMethod.farmerConfirmation,
            PickupConfirmationMethod.quantityConfirmation,
            PickupConfirmationMethod.weightConfirmation,
          },
      pickupCodeHash: PickupConfiguration.hashCodeValue('246810'),
      codeExpiresAt: expiresAt ?? DateTime(2031),
    ),
  },
);
Future<void> _reachPickupConfirmation(
  InMemoryRiderDeliveryRepository repository,
) async {
  var current = DeliveryStatus.accepted;
  for (final next in [
    DeliveryStatus.goingToPickup,
    DeliveryStatus.arrivedAtPickup,
    DeliveryStatus.waitingForProduct,
    DeliveryStatus.pickupConfirmationRequired,
  ]) {
    await repository.updateDeliveryStatus(_status(current, next));
    current = next;
  }
}

DeliveryStatusUpdateCommand _status(
  DeliveryStatus previous,
  DeliveryStatus next,
) => DeliveryStatusUpdateCommand(
  deliveryId: 'delivery-1',
  riderId: 'rider-a',
  previousStatus: previous,
  newStatus: next,
  idempotencyKey: next.name,
  location: _location,
);
PickupCompletionCommand _command({
  String? code = '246810',
  String key = 'complete',
  Map<PickupConfirmationMethod, String>? proofs,
  PickupConditionChecklist? condition,
}) => PickupCompletionCommand(
  deliveryId: 'delivery-1',
  riderId: 'rider-a',
  idempotencyKey: key,
  location: _location,
  checklist: condition ?? _condition(),
  confirmationCode: code,
  proofReferences:
      proofs ??
      {
        PickupConfirmationMethod.confirmationCode:
            'protected://pickup/delivery-1/code',
        PickupConfirmationMethod.farmerConfirmation:
            'protected://pickup/delivery-1/farmer',
        PickupConfirmationMethod.productPhoto:
            'protected://pickup/delivery-1/product-photo',
      },
);
PickupConditionChecklist _condition({bool fitsVehicle = true}) =>
    PickupConditionChecklist(
      correctProduct: true,
      correctQuantity: true,
      correctWeight: true,
      securePackaging: true,
      notVisiblyDamaged: true,
      matchesRequest: true,
      fitsVehicle: fitsVehicle,
      handlingInstructionsReceived: true,
      confirmedQuantity: 2,
      confirmedWeightKg: 10,
    );
DeliveryRequest _request() => DeliveryRequest(
  id: 'delivery-1',
  orderNumber: 'ORD-1',
  productName: 'Produce',
  sellerName: 'Farmer',
  buyerName: 'Buyer',
  pickupLocation: const DeliveryLocation(
    address: 'Farm',
    latitude: 8.48,
    longitude: 124.65,
  ),
  deliveryLocation: const DeliveryLocation(address: 'Buyer'),
  pickupDeadline: DateTime(2030),
  stage: DeliveryStage.accepted,
  assignedRiderId: 'rider-a',
);
