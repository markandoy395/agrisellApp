import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_acceptance.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'support/rider_acceptance_fixture.dart';

void main() {
  test('two Riders accepting simultaneously produce one assignment', () async {
    final repository = InMemoryRiderDeliveryRepository(
      requests: [acceptanceRequest()],
      riderStates: [
        acceptanceRider(),
        acceptanceRider(id: 'rider-b'),
      ],
      clock: () => acceptanceNow,
      beforeAcceptanceCommit: () => Future<void>.delayed(Duration.zero),
    );

    final outcomes = await Future.wait([
      _attempt(repository, acceptanceCommand()),
      _attempt(
        repository,
        acceptanceCommand(riderId: 'rider-b', key: 'rider-b-key'),
      ),
    ]);

    expect(outcomes.whereType<DeliveryAcceptanceReceipt>(), hasLength(1));
    expect(outcomes.whereType<DeliveryAcceptanceFailure>(), [
      DeliveryAcceptanceFailure.alreadyAssigned,
    ]);
    final winner = outcomes.whereType<DeliveryAcceptanceReceipt>().single;
    expect(winner.request.assignedRiderId, 'rider-a');
    expect(repository.activeDeliveryFor('rider-a')?.requestId, 'delivery-1');
    expect(repository.activeDeliveryFor('rider-b'), isNull);
  });

  test('same Rider repeated acceptance creates one active record', () async {
    final repository = _repository();
    final results = await Future.wait([
      repository.acceptDelivery(acceptanceCommand(key: 'first')),
      repository.acceptDelivery(acceptanceCommand(key: 'second')),
      repository.acceptDelivery(acceptanceCommand(key: 'third')),
    ]);

    expect(results.map((item) => item.activeDelivery.id).toSet(), hasLength(1));
    expect(results.first.isIdempotentReplay, isFalse);
    expect(results.skip(1).every((item) => item.isIdempotentReplay), isTrue);
  });

  test('duplicate network request returns the stored receipt', () async {
    final repository = _repository();
    final first = await repository.acceptDelivery(acceptanceCommand());
    final replay = await repository.acceptDelivery(acceptanceCommand());

    expect(replay.isIdempotentReplay, isTrue);
    expect(replay.activeDelivery.id, first.activeDelivery.id);
    expect(replay.request.assignedRiderId, first.request.assignedRiderId);
  });

  test('transaction failure rolls back all acceptance writes', () async {
    final repository = InMemoryRiderDeliveryRepository(
      requests: [acceptanceRequest()],
      riderStates: [acceptanceRider()],
      clock: () => acceptanceNow,
      beforeAcceptanceCommit: () => throw StateError('database failed'),
    );

    final failure = await captureAcceptanceFailure(
      repository.acceptDelivery(acceptanceCommand()),
    );

    expect(failure, DeliveryAcceptanceFailure.transactionFailed);
    expect(repository.activeDeliveryFor('rider-a'), isNull);
    expect(
      repository.authoritativeRiderState('rider-a')?.availability,
      RiderAvailability.onlineAvailable,
    );
    final request = (await repository.fetchRequests(riderId: 'rider-a')).single;
    expect(request.stage, DeliveryStage.readyForPickup);
    expect(request.assignedRiderId, isNull);
  });

  test('success creates active delivery and reserves Rider status', () async {
    final repository = _repository();
    final receipt = await repository.acceptDelivery(acceptanceCommand());

    expect(receipt.request.stage, DeliveryStage.accepted);
    expect(receipt.activeDelivery.riderId, 'rider-a');
    expect(receipt.activeDelivery.estimatedEarning, 180);
    expect(receipt.riderAvailability, RiderAvailability.deliveryReserved);
    final rider = repository.authoritativeRiderState('rider-a')!;
    expect(rider.availability, RiderAvailability.deliveryReserved);
    expect(rider.activeDeliveryCount, 1);
  });
}

InMemoryRiderDeliveryRepository _repository() =>
    InMemoryRiderDeliveryRepository(
      requests: [acceptanceRequest()],
      riderStates: [acceptanceRider()],
      clock: () => acceptanceNow,
    );

Future<Object> _attempt(
  InMemoryRiderDeliveryRepository repository,
  DeliveryAcceptanceCommand command,
) async {
  try {
    return await repository.acceptDelivery(command);
  } on DeliveryAcceptanceException catch (error) {
    return error.failure;
  }
}
