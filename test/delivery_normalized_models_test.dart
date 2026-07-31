import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_bundle.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_location.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_payment_record.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_priority.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_proof.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_requirement.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_history.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_transition_validator.dart';

void main() {
  const created = '2026-07-16T01:00:00Z';

  test('delivery safely parses the final ERD values', () {
    final delivery = Delivery.fromJson({
      'delivery_id': 42,
      'order_id': 8,
      'delivery_status': 'picked_up',
      'estimated_delivery_time': '2026-07-16T02:00:00Z',
      'actual_delivery_time': null,
      'vehicle_types': 'motorcycle',
      'cold_chain_available': false,
      'pickup_location': 'Carmen Market',
      'dropoff_location': 'Uptown Buyer',
      'distance_km': '4',
      'created_at': created,
    });

    expect(delivery.deliveryId, '42');
    expect(delivery.deliveryStatus, DeliveryStatus.productPickedUp);
    expect(delivery.priority, DeliveryPriority.standard);
    expect(delivery.pickupLocation, 'Carmen Market');
    expect(delivery.distanceKm, 4);
    expect(delivery.toJson()['delivery_status'], 'picked_up');
    expect(delivery.toJson(), isNot(contains('priority')));
  });

  test('location requires database coordinates and maps snake case', () {
    final location = DeliveryLocation.fromJson({
      'location_id': 'location-1',
      'delivery_id': 42,
      'location_type': 'pickup',
      'address': 'Carmen Public Market',
      'latitude': '8.4822',
      'longitude': 124.647,
      'sequence_number': 1,
      'created_at': created,
      'updated_at': created,
    });

    expect(location.locationType, DeliveryLocationType.pickup);
    expect(location.hasCoordinates, isTrue);
    expect(location.toJson()['delivery_id'], '42');
    expect(
      () => DeliveryLocation.fromJson({
        'location_type': 'pickup',
        'address': 'Missing pin',
      }),
      throwsFormatException,
    );
  });

  test('requirements, history, proof, and payment parse typed fields', () {
    final requirement = DeliveryRequirement.fromJson({
      'requirement_id': 'requirement-1',
      'delivery_id': 42,
      'minimum_capacity_kg': '20',
      'requires_cooling': true,
      'requires_fragile_handling': false,
      'requires_waterproof_cover': true,
      'requires_special_handling': true,
      'created_at': created,
      'updated_at': created,
    });
    final history = DeliveryStatusHistory.fromJson({
      'status_history_id': 'history-1',
      'delivery_id': 42,
      'previous_status': 'accepted',
      'new_status': 'going_to_pickup',
      'changed_at': created,
      'created_at': created,
    });
    final proof = DeliveryProof.fromJson({
      'proof_id': 'proof-1',
      'delivery_id': 42,
      'proof_stage': 'delivery',
      'proof_type': 'signature',
      'file_path': 'user/42/delivery/signature.png',
      'created_at': created,
      'updated_at': created,
    });
    final payment = DeliveryPayment.fromJson({
      'delivery_payment_id': 'payment-1',
      'delivery_id': 42,
      'delivery_fee': '100',
      'additional_fee': 20,
      'deduction_amount': 5,
      'final_earning': 115,
      'earning_status': 'approved',
      'payout_status': 'unpaid',
      'created_at': created,
      'updated_at': created,
    });

    expect(requirement.requiresCooling, isTrue);
    expect(history.newStatus, DeliveryStatus.goingToPickup);
    expect(proof.type, DeliveryProofType.buyerSignature);
    expect(payment.finalEarning, 115);
  });

  test('canonical transition validator rejects skipped steps', () {
    const validator = DeliveryTransitionValidator();
    expect(
      validator.canTransition(DeliveryStatus.pending, DeliveryStatus.available),
      isTrue,
    );
    expect(
      validator.canTransition(
        DeliveryStatus.available,
        DeliveryStatus.goingToPickup,
      ),
      isFalse,
    );
    expect(DeliveryStatus.deliveryCompleted.databaseValue, 'completed');
  });

  test('delivery bundle keeps secure fulfillment coordinates and rules', () {
    final bundle = DeliveryBundle.fromJson({
      'delivery_id': 42,
      'order_id': 8,
      'delivery_status': 'available',
      'created_at': created,
      'pickup_location': 'Carmen Market',
      'dropoff_location': 'Uptown Buyer',
      'locations': [
        {
          'location_id': 'pickup-42',
          'delivery_id': 42,
          'location_type': 'pickup',
          'address': 'Carmen Market',
          'latitude': 8.48,
          'longitude': 124.64,
          'created_at': created,
          'updated_at': created,
        },
      ],
      'requirement': {
        'requirement_id': 'requirement-42',
        'delivery_id': 42,
        'minimum_capacity_kg': 25,
        'requires_cooling': false,
        'requires_fragile_handling': true,
        'requires_waterproof_cover': true,
        'requires_special_handling': true,
        'created_at': created,
        'updated_at': created,
      },
      'history': [
        {
          'status_history_id': 'event-1',
          'delivery_id': 42,
          'previous_status': 'available',
          'new_status': 'accepted',
          'changed_at': created,
          'created_at': created,
        },
      ],
    });

    expect(bundle.pickup?.hasCoordinates, isTrue);
    expect(bundle.requirement?.minimumCapacityKg, 25);
    expect(bundle.history.single.newStatus, DeliveryStatus.accepted);
  });
}
