import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_errors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_proof.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_update.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_live_location_policy.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';

import 'support/rider_completion_fixture.dart';
import 'support/rider_test_models.dart';

void main() {
  test(
    'Buyer arrival validates radius and starts waiting with notification',
    () async {
      final repository = completionRepository();
      await reachGoingToBuyer(repository);
      await expectLater(
        repository.updateDeliveryStatus(
          buyerArrivalCommand(
            location: completionLocation(latitude: 8.7, longitude: 124.9),
          ),
        ),
        throwsA(isA<DeliveryDomainException>()),
      );
      final arrived = await repository.updateDeliveryStatus(
        buyerArrivalCommand(),
      );
      expect(arrived.currentStatus, DeliveryStatus.arrivedAtDelivery);
      expect(repository.buyerArrivalNotified('delivery-1'), isTrue);
      expect(repository.deliveryWaitingStartedAt('delivery-1'), isNotNull);
    },
  );

  test('manual Buyer arrival override records valid GPS evidence', () async {
    final repository = completionRepository();
    await reachGoingToBuyer(repository);
    final arrived = await repository.updateDeliveryStatus(
      buyerArrivalCommand(
        location: completionLocation(accuracy: 80),
        manual: true,
      ),
    );
    expect(arrived.events.last.isManualArrivalOverride, isTrue);
    expect(arrived.events.last.reasonCode, 'location_inaccurate');
    expect(arrived.events.last.locationTimestamp, isNotNull);
  });

  test(
    'correct code completes atomically and creates immutable history',
    () async {
      final repository = completionRepository();
      await reachDeliveryConfirmation(repository);
      final result = await repository.completeDelivery(completionCommand());
      final replay = await repository.completeDelivery(completionCommand());
      expect(result.record.request.stage.name, 'completed');
      expect(result.record.events.takeLast(2).map((event) => event.newStatus), [
        DeliveryStatus.productDelivered,
        DeliveryStatus.deliveryCompleted,
      ]);
      expect(result.record.buyerNotified, isTrue);
      expect(result.record.farmerNotified, isTrue);
      expect(result.record.request.proofs, isNotEmpty);
      final evidence = result.record.request.proofs.singleWhere(
        (proof) => proof.type == DeliveryProofType.deliveryPhoto,
      );
      expect(evidence.capturedAt, isNotNull);
      expect(evidence.latitude, closeTo(8.49, 0.001));
      expect(evidence.longitude, closeTo(124.66, 0.001));
      expect(replay.record.events.length, result.record.events.length);
      expect(await repository.fetchActiveDeliveryStatus('rider-a'), isNull);
      expect(
        await repository.fetchCompletedDeliveries('rider-a'),
        hasLength(1),
      );
      await expectLater(
        repository.updateDeliveryStatus(
          DeliveryStatusUpdateCommand(
            deliveryId: 'delivery-1',
            riderId: 'rider-a',
            previousStatus: DeliveryStatus.deliveryCompleted,
            newStatus: DeliveryStatus.accepted,
            idempotencyKey: 'edit-completed',
          ),
        ),
        throwsA(isA<DeliveryDomainException>()),
      );
    },
  );

  test(
    'incorrect, expired, missing proof, and repeated completion fail',
    () async {
      final repository = completionRepository();
      await reachDeliveryConfirmation(repository);
      await expectLater(
        repository.completeDelivery(completionCommand(code: '000000')),
        throwsA(isA<DeliveryDomainException>()),
      );
      await expectLater(
        repository.completeDelivery(completionCommand(proofs: const {})),
        throwsA(isA<DeliveryDomainException>()),
      );
      await repository.completeDelivery(completionCommand(key: 'valid'));
      await expectLater(
        repository.completeDelivery(
          completionCommand(key: 'duplicate-new-key'),
        ),
        throwsA(
          isA<DeliveryDomainException>().having(
            (error) => error.message,
            'message',
            contains('already been used'),
          ),
        ),
      );

      final expired = completionRepository(expiresAt: DateTime(2020));
      await reachDeliveryConfirmation(expired);
      await expectLater(
        expired.completeDelivery(completionCommand()),
        throwsA(isA<DeliveryDomainException>()),
      );
    },
  );

  test('too many invalid delivery-code attempts are blocked', () async {
    final repository = completionRepository(maxAttempts: 2);
    await reachDeliveryConfirmation(repository);
    for (final key in ['wrong-1', 'wrong-2']) {
      await expectLater(
        repository.completeDelivery(
          completionCommand(code: '000000', key: key),
        ),
        throwsA(isA<DeliveryDomainException>()),
      );
    }
    await expectLater(
      repository.completeDelivery(completionCommand(key: 'locked')),
      throwsA(
        isA<DeliveryDomainException>().having(
          (error) => error.message,
          'message',
          contains('Too many'),
        ),
      ),
    );
  });

  test('controller clears active state and returns Rider online', () async {
    final repository = completionRepository();
    await reachDeliveryConfirmation(repository);
    final controller = RiderDeliveryController(repository: repository)
      ..updateProfile(verifiedRiderProfile());
    await controller.applyAuthoritativeAvailability(
      RiderAvailability.waitingAtDeliveryLocation,
      loadRequests: false,
    );
    await controller.load(riderId: 'rider-a');
    await controller.refreshActiveDelivery();
    final result = await controller.completeDelivery(
      command: completionCommand(),
    );
    expect(result.isSuccess, isTrue);
    expect(controller.hasActiveDelivery, isFalse);
    expect(controller.completionHistory, hasLength(1));
    expect(controller.status.availability, RiderAvailability.onlineAvailable);
    expect(
      isLiveLocationSharingStage(DeliveryStatus.deliveryCompleted),
      isFalse,
    );
    controller.dispose();
  });
}

extension<T> on Iterable<T> {
  Iterable<T> takeLast(int count) => skip(length - count);
}
