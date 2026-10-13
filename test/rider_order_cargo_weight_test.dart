import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/data/supabase_delivery_acceptance_failure_mapper.dart';
import 'package:agresell_app/features/rider/deliveries/data/supabase_delivery_data_source.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_acceptance.dart';
import 'support/rider_batch_fixture.dart';

void main() {
  test(
    'mixed items fill capacity exactly; next order is rejected by weight',
    () async {
      final repository = InMemoryRiderDeliveryRepository(
        requests: [
          batchRequest(id: 'vegetables', weightKg: 3 + 2),
          batchRequest(id: 'fruit', weightKg: 10),
          batchRequest(id: 'extra', weightKg: 1),
        ],
        riderStates: [batchRiderState(capacityKg: 15)],
        clock: () => batchNow,
      );
      for (final id in ['vegetables', 'fruit']) {
        await repository.acceptDelivery(
          DeliveryAcceptanceCommand(
            requestId: id,
            riderId: 'rider-a',
            idempotencyKey: id,
          ),
        );
      }
      expect(repository.activeDeliveriesFor('rider-a'), hasLength(2));
      await expectLater(
        repository.acceptDelivery(
          const DeliveryAcceptanceCommand(
            requestId: 'extra',
            riderId: 'rider-a',
            idempotencyKey: 'extra',
          ),
        ),
        throwsA(
          isA<DeliveryAcceptanceException>().having(
            (e) => e.failure,
            'failure',
            DeliveryAcceptanceFailure.capacityMismatch,
          ),
        ),
      );
    },
  );
  test('unknown order mass reports verified kilograms are required', () {
    final failure = SupabaseDeliveryAcceptanceFailureMapper.map(
      const DeliveryDataException(
        DeliveryDataFailureType.validation,
        'cargo_weight_unknown',
      ),
    );
    expect(failure, DeliveryAcceptanceFailure.cargoWeightUnknown);
    expect(failure.userMessage, contains('kilograms must be verified'));
  });
}
