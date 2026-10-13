import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/features/rider/profile/data/rider_profile_entity_mapper.dart';
import 'package:agresell_app/features/rider/profile/domain/rider.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_vehicle.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_acceptance.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'support/rider_batch_fixture.dart';

void main() {
  test(
    'server capacity reaches the profile and is excluded from profile writes',
    () {
      final rider = Rider.fromJson({
        'rider_id': 'rider-a',
        'vehicle_type': 'motorcycle',
        'capacity_kg': '3.000',
        'maximum_active_deliveries': 3,
        'employment_status': 'active',
      });
      final copied = rider.copyWith(fullName: 'Rider');
      final profile = riderProfileFromEntities(
        copied,
        const RiderVehicle(
          vehicleId: 'rider-a',
          riderId: 'rider-a',
          vehicleType: 'motorcycle',
          vehicleModel: '',
          vehicleColor: '',
          plateNumber: 'ABC123',
          capacityKg: 0,
        ),
        [],
        null,
        null,
      );
      expect(profile.capacityKg, 3);
      expect(profile.maximumActiveDeliveries, 3);
      expect(copied.toJson().containsKey('capacity_kg'), isFalse);
    },
  );

  test(
    'three 1 kg orders fit a configured 3 kg motorcycle, fourth hits count limit',
    () async {
      final repository = InMemoryRiderDeliveryRepository(
        requests: [
          for (final id in ['a', 'b', 'c', 'd'])
            batchRequest(id: id, weightKg: 1),
        ],
        riderStates: [batchRiderState(capacityKg: 3)],
        clock: () => batchNow,
      );
      for (final id in ['a', 'b', 'c']) {
        await repository.acceptDelivery(
          DeliveryAcceptanceCommand(
            requestId: id,
            riderId: 'rider-a',
            idempotencyKey: id,
          ),
        );
      }
      expect(repository.activeDeliveriesFor('rider-a'), hasLength(3));
      await expectLater(
        repository.acceptDelivery(
          const DeliveryAcceptanceCommand(
            requestId: 'd',
            riderId: 'rider-a',
            idempotencyKey: 'd',
          ),
        ),
        throwsA(
          isA<DeliveryAcceptanceException>().having(
            (error) => error.failure,
            'failure',
            DeliveryAcceptanceFailure.activeDeliveryLimit,
          ),
        ),
      );
    },
  );

  test(
    'combined weight still rejects the third 1 kg order with a 2 kg capacity',
    () async {
      final repository = InMemoryRiderDeliveryRepository(
        requests: [
          for (final id in ['a', 'b', 'c']) batchRequest(id: id, weightKg: 1),
        ],
        riderStates: [batchRiderState(capacityKg: 2)],
        clock: () => batchNow,
      );
      for (final id in ['a', 'b']) {
        await repository.acceptDelivery(
          DeliveryAcceptanceCommand(
            requestId: id,
            riderId: 'rider-a',
            idempotencyKey: id,
          ),
        );
      }
      await expectLater(
        repository.acceptDelivery(
          const DeliveryAcceptanceCommand(
            requestId: 'c',
            riderId: 'rider-a',
            idempotencyKey: 'c',
          ),
        ),
        throwsA(
          isA<DeliveryAcceptanceException>().having(
            (error) => error.failure,
            'failure',
            DeliveryAcceptanceFailure.capacityMismatch,
          ),
        ),
      );
    },
  );
}
