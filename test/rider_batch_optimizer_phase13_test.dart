import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery_request_metadata.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_payment.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_batch_delivery.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_batch_optimizer.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_registration.dart';
import 'support/rider_batch_fixture.dart';

void main() {
  const optimizer = RiderBatchOptimizer();

  test('two compatible deliveries produce separate optimized stops', () {
    final first = batchRequest(id: 'a', earning: 100);
    final second = batchRequest(
      id: 'b',
      pickupLatitude: 8.482,
      deliveryLatitude: 8.5,
      earning: 140,
    );
    final result = optimizer.evaluate(
      activeDeliveries: [first],
      candidate: second,
      context: _context(),
    );

    expect(result.isEligible, isTrue);
    expect(result.plan?.deliveries, hasLength(2));
    expect(result.plan?.pickupSequence, hasLength(2));
    expect(result.plan?.deliverySequence, hasLength(2));
    expect(result.plan?.combinedEarning, 240);
    expect(result.plan?.remainingCapacityKg, 60);
  });

  test('combined capacity and active-delivery limits are enforced', () {
    final capacity = optimizer.evaluate(
      activeDeliveries: [batchRequest(id: 'a', weightKg: 60)],
      candidate: batchRequest(id: 'b', weightKg: 50),
      context: _context(),
    );
    final limit = optimizer.evaluate(
      activeDeliveries: [batchRequest(id: 'a')],
      candidate: batchRequest(id: 'b'),
      context: _context(maximumActive: 1),
    );

    expect(capacity.rejection, RiderBatchRejection.capacityExceeded);
    expect(limit.rejection, RiderBatchRejection.activeDeliveryLimit);
  });

  test('incompatible and exclusive products cannot be grouped', () {
    final incompatible = optimizer.evaluate(
      activeDeliveries: [batchRequest(id: 'a', compatibilityGroup: 'fresh')],
      candidate: batchRequest(id: 'b', compatibilityGroup: 'chemical'),
      context: _context(),
    );
    final exclusive = optimizer.evaluate(
      activeDeliveries: [batchRequest(id: 'a')],
      candidate: batchRequest(id: 'b', exclusive: true),
      context: _context(),
    );

    expect(incompatible.rejection, RiderBatchRejection.productConflict);
    expect(exclusive.rejection, RiderBatchRejection.exclusiveTransport);
  });

  test('temperature conflicts and missing fragile protection are rejected', () {
    const chilled = ProductHandlingRequirement(
      type: ProductHandlingType.temperatureSensitive,
      instructions: '2-4 C',
    );
    const frozen = ProductHandlingRequirement(
      type: ProductHandlingType.temperatureSensitive,
      instructions: '-18 C',
    );
    const fragile = ProductHandlingRequirement(
      type: ProductHandlingType.fragile,
    );
    final temperatures = optimizer.evaluate(
      activeDeliveries: [
        batchRequest(id: 'a', handling: const [chilled]),
      ],
      candidate: batchRequest(id: 'b', handling: const [frozen]),
      context: _context(),
    );
    final protection = optimizer.evaluate(
      activeDeliveries: [
        batchRequest(id: 'a', handling: const [fragile]),
      ],
      candidate: batchRequest(id: 'b'),
      context: _context(capabilities: const {}),
    );

    expect(temperatures.rejection, RiderBatchRejection.temperatureConflict);
    expect(protection.rejection, RiderBatchRejection.fragileProtectionRequired);
  });

  test('pickup and delivery sequences prioritize their deadlines', () {
    final first = batchRequest(
      id: 'a',
      pickupWindow: const Duration(hours: 1),
      deliveryWindow: const Duration(hours: 3),
    );
    final urgent = batchRequest(
      id: 'b',
      pickupWindow: const Duration(minutes: 30),
      deliveryWindow: const Duration(hours: 2),
    );
    final result = optimizer.evaluate(
      activeDeliveries: [first],
      candidate: urgent,
      context: _context(),
    );

    expect(result.plan?.pickupSequence.first.deliveryId, 'b');
    expect(result.plan?.deliverySequence.first.deliveryId, 'b');
  });

  test('impossible deadlines and unreasonable routes are rejected', () {
    final deadline = optimizer.evaluate(
      activeDeliveries: [batchRequest(id: 'a')],
      candidate: batchRequest(
        id: 'b',
        pickupLatitude: 9,
        pickupLongitude: 125,
        pickupWindow: const Duration(minutes: 1),
      ),
      context: _context(maximumDistance: 500),
    );
    final route = optimizer.evaluate(
      activeDeliveries: [batchRequest(id: 'a')],
      candidate: batchRequest(id: 'b', pickupLatitude: 9, pickupLongitude: 125),
      context: _context(maximumDistance: 5),
    );

    expect(deadline.rejection, RiderBatchRejection.deadlineConflict);
    expect(route.rejection, RiderBatchRejection.routeIncompatible);
  });

  test('vehicle, handling, and COD responsibilities are validated', () {
    final vehicle = optimizer.evaluate(
      activeDeliveries: [batchRequest(id: 'a')],
      candidate: batchRequest(id: 'b'),
      context: _context(vehicleType: RiderVehicleType.van),
    );
    final handling = optimizer.evaluate(
      activeDeliveries: [batchRequest(id: 'a')],
      candidate: batchRequest(
        id: 'b',
        handling: const [
          ProductHandlingRequirement(
            type: ProductHandlingType.temperatureSensitive,
          ),
        ],
      ),
      context: _context(capabilities: const {'fragileProtection'}),
    );
    final cod = optimizer.evaluate(
      activeDeliveries: [batchRequest(id: 'a')],
      candidate: batchRequest(
        id: 'b',
        cashOnDelivery: const CashOnDeliveryRequirement(amountToCollect: 500),
      ),
      context: _context(),
    );

    expect(vehicle.rejection, RiderBatchRejection.vehicleIncompatible);
    expect(handling.rejection, RiderBatchRejection.handlingCapabilityRequired);
    expect(cod.rejection, RiderBatchRejection.codResponsibilityUnavailable);
  });

  test('picked-up delivery has no second pickup stop', () {
    final result = optimizer.evaluate(
      activeDeliveries: [batchRequest(id: 'a', stage: DeliveryStage.pickedUp)],
      candidate: batchRequest(id: 'b'),
      context: _context(),
    );

    expect(result.plan?.pickupSequence.map((stop) => stop.deliveryId), ['b']);
    expect(result.plan?.deliverySequence.map((stop) => stop.deliveryId), [
      'a',
      'b',
    ]);
  });
}

RiderBatchContext _context({
  int maximumActive = 3,
  double maximumDistance = 100,
  Set<String> capabilities = const {
    'fragileProtection',
    'temperatureSensitive',
  },
  RiderVehicleType vehicleType = RiderVehicleType.motorcycle,
}) => RiderBatchContext(
  riderEligible: true,
  maximumActiveDeliveries: maximumActive,
  capacityKg: 100,
  now: batchNow,
  currentLocation: const RiderDeliverySearch(latitude: 8.48, longitude: 124.65),
  vehicleType: vehicleType,
  handlingCapabilityKeys: capabilities,
  maximumBatchDistanceKm: maximumDistance,
);
