import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_request_query.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_registration.dart';
import 'package:agresell_app/features/shared/orders/domain/rider_assignment_request_status.dart';

void main() {
  test(
    'farmer-selected request remains visible despite nearby rejection',
    () async {
      final now = DateTime(2026, 8, 10, 10);
      final repository = InMemoryRiderDeliveryRepository(
        requests: [_farmerRequest(now)],
        clock: () => now,
      );

      final page = await repository.fetchNearbyRequests(_query());

      expect(page.items.map((request) => request.id), ['delivery-1']);
    },
  );

  test('expired farmer-selected request stays hidden', () async {
    final now = DateTime(2026, 8, 10, 10);
    final repository = InMemoryRiderDeliveryRepository(
      requests: [
        _farmerRequest(
          now,
          expiresAt: now.subtract(const Duration(seconds: 1)),
        ),
      ],
      clock: () => now,
    );

    final page = await repository.fetchNearbyRequests(_query());

    expect(page.items, isEmpty);
  });
}

RiderRequestQuery _query() => const RiderRequestQuery(
  matching: RiderMatchingContext(
    riderId: 'rider-1',
    availability: RiderAvailability.onlineAvailable,
    vehicleType: RiderVehicleType.motorcycle,
    capacityKg: 50,
    serviceArea: 'Cagayan de Oro',
    serviceRadiusKm: 15,
    registeredLatitude: 8.48,
    registeredLongitude: 124.65,
    activeDeliveryCount: 0,
  ),
);

DeliveryRequest _farmerRequest(DateTime now, {DateTime? expiresAt}) =>
    DeliveryRequest(
      id: 'delivery-1',
      orderNumber: 'Order #1',
      productName: 'Tomatoes',
      sellerName: 'Farmer',
      buyerName: 'Buyer',
      pickupLocation: const DeliveryLocation(address: 'Farm'),
      deliveryLocation: const DeliveryLocation(address: 'Buyer address'),
      pickupDeadline: now.add(const Duration(minutes: 15)),
      deliveryDeadline: now.add(const Duration(minutes: 15)),
      expiresAt: expiresAt ?? now.add(const Duration(minutes: 15)),
      assignmentRequestId: 'request-1',
      assignmentRequestStatus: RiderAssignmentRequestStatus.pending,
    );
