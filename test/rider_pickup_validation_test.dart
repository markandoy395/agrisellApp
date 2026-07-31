import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_errors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_update.dart';
import 'package:agresell_app/features/rider/deliveries/domain/pickup_confirmation.dart';

void main() {
  test(
    'QR payload is validated and pickup record retains condition data',
    () async {
      final repository = _repository(
        methods: {PickupConfirmationMethod.qrCode},
        qrHash: PickupConfiguration.hashQrPayload('qr-2468'),
      );
      await _reachConfirmation(repository);
      await expectLater(
        repository.completePickup(_command(qr: 'wrong')),
        throwsA(isA<DeliveryDomainException>()),
      );
      final result = await repository.completePickup(_command(qr: 'qr-2468'));
      expect(result.record?.checklist.correctProduct, isTrue);
      expect(result.record?.location.latitude, 8.48);
      expect(repository.pickupRecordFor('delivery-1'), isNotNull);
      expect(repository.pickupWaitingStartedAt('delivery-1'), isNotNull);
    },
  );

  test('quantity and weight mismatches block pickup completion', () async {
    final repository = _repository();
    await _reachConfirmation(repository);
    await expectLater(
      repository.completePickup(_command(quantity: 3)),
      throwsA(isA<DeliveryDomainException>()),
    );
    await expectLater(
      repository.completePickup(_command(weight: 9.5, key: 'wrong-weight')),
      throwsA(isA<DeliveryDomainException>()),
    );
  });
}

InMemoryRiderDeliveryRepository _repository({
  Set<PickupConfirmationMethod> methods = const {
    PickupConfirmationMethod.confirmationCode,
    PickupConfirmationMethod.farmerConfirmation,
  },
  String? qrHash,
}) => InMemoryRiderDeliveryRepository(
  requests: [_request()],
  pickupConfigurations: {
    'delivery-1': PickupConfiguration(
      requiredMethods: methods,
      pickupCodeHash: PickupConfiguration.hashCodeValue('246810'),
      qrPayloadHash: qrHash,
      codeExpiresAt: DateTime(2031),
    ),
  },
);

Future<void> _reachConfirmation(
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

DeliveryStatusUpdateCommand _status(DeliveryStatus from, DeliveryStatus to) =>
    DeliveryStatusUpdateCommand(
      deliveryId: 'delivery-1',
      riderId: 'rider-a',
      previousStatus: from,
      newStatus: to,
      idempotencyKey: to.name,
      location: _location,
    );

PickupCompletionCommand _command({
  String qr = 'unused',
  String key = 'complete',
  int quantity = 2,
  double weight = 10,
}) => PickupCompletionCommand(
  deliveryId: 'delivery-1',
  riderId: 'rider-a',
  idempotencyKey: key,
  location: _location,
  checklist: PickupConditionChecklist(
    correctProduct: true,
    correctQuantity: true,
    correctWeight: true,
    securePackaging: true,
    notVisiblyDamaged: true,
    matchesRequest: true,
    fitsVehicle: true,
    handlingInstructionsReceived: true,
    confirmedQuantity: quantity,
    confirmedWeightKg: weight,
  ),
  confirmationCode: '246810',
  qrPayload: qr,
  proofReferences: {
    PickupConfirmationMethod.confirmationCode: 'protected://code',
    PickupConfirmationMethod.farmerConfirmation: 'protected://farmer',
    PickupConfirmationMethod.qrCode: 'protected://qr',
  },
);

final _location = DeliveryStatusLocation(
  latitude: 8.48,
  longitude: 124.65,
  accuracyMeters: 5,
  timestamp: DateTime.now(),
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
  quantityDescription: '2 units',
  totalWeightKg: 10,
  stage: DeliveryStage.accepted,
  assignedRiderId: 'rider-a',
);
