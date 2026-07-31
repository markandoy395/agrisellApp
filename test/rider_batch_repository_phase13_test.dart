import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_acceptance.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_payment.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_proof.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'support/rider_batch_fixture.dart';

part 'support/rider_batch_repository_support.dart';

void main() {
  test(
    'backend accepts two compatible deliveries without overwriting either',
    () async {
      final harness = await _harness();
      addTearDown(harness.controller.dispose);

      expect(
        (await harness.controller.accept(
          requestId: 'a',
          riderId: 'rider-a',
        )).isSuccess,
        isTrue,
      );
      expect(
        (await harness.controller.accept(
          requestId: 'b',
          riderId: 'rider-a',
        )).isSuccess,
        isTrue,
      );

      expect(harness.controller.activeDeliveryRequests, hasLength(2));
      expect(harness.controller.activeDeliveryRecords, hasLength(2));
      expect(harness.repository.activeDeliveriesFor('rider-a'), hasLength(2));
      expect(harness.controller.statusEventsFor('a').single.deliveryId, 'a');
      expect(harness.controller.statusEventsFor('b').single.deliveryId, 'b');
      expect(harness.controller.batchPlan?.stops, hasLength(4));
    },
  );

  test('backend atomically rejects an incompatible second delivery', () async {
    final repository = InMemoryRiderDeliveryRepository(
      requests: [
        batchRequest(id: 'a', compatibilityGroup: 'fresh'),
        batchRequest(id: 'b', compatibilityGroup: 'chemical'),
      ],
      riderStates: [batchRiderState()],
      clock: () => batchNow,
    );
    await repository.acceptDelivery(_accept('a', 'first'));

    await expectLater(
      repository.acceptDelivery(_accept('b', 'second')),
      throwsA(
        isA<DeliveryAcceptanceException>().having(
          (error) => error.failure,
          'failure',
          DeliveryAcceptanceFailure.batchIncompatible,
        ),
      ),
    );
    expect(repository.activeDeliveriesFor('rider-a'), hasLength(1));
    expect(
      repository.authoritativeRiderState('rider-a')?.activeDeliveryCount,
      1,
    );
  });

  test(
    'cancelling one delivery keeps the other active and recalculates route',
    () async {
      final harness = await _harness();
      addTearDown(harness.controller.dispose);
      await harness.controller.accept(requestId: 'a', riderId: 'rider-a');
      await harness.controller.accept(requestId: 'b', riderId: 'rider-a');
      final originalDistance = harness.controller.batchPlan!.totalDistanceKm;

      final result = await harness.controller.cancel(
        requestId: 'a',
        riderId: 'rider-a',
        reason: 'Request cancelled before pickup',
      );

      expect(result.isSuccess, isTrue);
      expect(harness.controller.activeDeliveryRequests.single.id, 'b');
      expect(
        harness.repository.activeDeliveriesFor('rider-a').single.requestId,
        'b',
      );
      expect(
        harness.repository
            .authoritativeRiderState('rider-a')
            ?.activeDeliveryCount,
        1,
      );
      expect(
        harness.controller.batchPlan!.totalDistanceKm,
        lessThan(originalDistance),
      );
    },
  );

  test(
    'proof, COD payment, and earnings remain keyed to each delivery',
    () async {
      const cod = CashOnDeliveryRequirement(amountToCollect: 850);
      final repository = InMemoryRiderDeliveryRepository(
        requests: [
          batchRequest(id: 'a', earning: 100),
          batchRequest(id: 'b', earning: 220, cashOnDelivery: cod),
        ],
        riderStates: [batchRiderState()],
        clock: () => batchNow,
      );
      await repository.acceptDelivery(_accept('a', 'first'));
      await repository.acceptDelivery(_accept('b', 'second'));
      await _pickupWithProof(repository, 'a', 'proof-a');
      await _pickupWithProof(repository, 'b', 'proof-b');
      final assigned = await repository.fetchRequests(riderId: 'rider-a');
      final byId = {for (final request in assigned) request.id: request};

      expect(byId['a']?.proofs.single.secureReference, 'protected://proof-a');
      expect(byId['b']?.proofs.single.secureReference, 'protected://proof-b');
      expect(byId['a']?.cashOnDelivery, isNull);
      expect(byId['b']?.cashOnDelivery?.amountToCollect, 850);
      expect(byId['a']?.deliveryFee, 100);
      expect(byId['b']?.deliveryFee, 220);
    },
  );

  test(
    'failed or returned terminal item does not corrupt remaining plan',
    () async {
      final controller = RiderDeliveryController(
        repository: InMemoryRiderDeliveryRepository(
          requests: [
            batchRequest(
              id: 'failed',
              stage: DeliveryStage.failed,
              assignedRiderId: 'rider-a',
            ),
            batchRequest(
              id: 'active',
              stage: DeliveryStage.accepted,
              assignedRiderId: 'rider-a',
            ),
          ],
        ),
      )..updateProfile(batchRiderProfile());
      addTearDown(controller.dispose);
      await controller.applyAuthoritativeAvailability(
        RiderAvailability.deliveryReserved,
        loadRequests: false,
      );
      await controller.load(riderId: 'rider-a');

      expect(controller.activeDeliveryRequests.single.id, 'active');
      expect(controller.batchPlan?.deliveries.single.id, 'active');
      expect(controller.batchPlan?.combinedWeightKg, 20);
    },
  );
}
