import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_acceptance.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_acceptance_state.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_ordering.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_request_matcher.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_request_query.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_registration.dart';

void main() {
  test(
    'registered coverage authorizes pickup independently of current GPS',
    () {
      final rider = _rider(
        current: const RiderDeliverySearch(latitude: 8.60, longitude: 124.65),
      );
      final request = _request(id: 'inside', latitude: 8.49);

      expect(rider.isCurrentLocationInsideRegisteredServiceArea, isFalse);
      expect(riderRequestRejection(request, rider), isNull);
    },
  );

  test('pickup outside current GPS search radius is not eligible', () {
    final rejection = riderRequestRejection(
      _request(id: 'outside', latitude: 8.54),
      _rider(
        current: const RiderDeliverySearch(
          latitude: 8.49,
          longitude: 124.65,
          radiusKm: 3,
        ),
      ),
    );

    expect(rejection, RiderRequestRejection.outsideServiceRadius);
  });

  test(
    'distance and sorting use current GPS instead of registered location',
    () {
      final rider = _rider(
        current: const RiderDeliverySearch(latitude: 8.50, longitude: 124.65),
      );
      final nearerToCurrent = _request(id: 'current', latitude: 8.501);
      final nearerToRegistered = _request(id: 'registered', latitude: 8.481);
      final requests = [nearerToRegistered, nearerToCurrent];

      sortRiderRequests(
        requests,
        RiderRequestSort.nearestPickup,
        pickupDistanceKm: rider.pickupDistanceKm,
      );

      expect(rider.pickupDistanceKm(nearerToCurrent), lessThan(0.2));
      expect(requests.map((item) => item.id), ['current', 'registered']);
    },
  );

  test(
    'registered-location fallback is labelled-only and cannot authorize acceptance',
    () {
      final fallback = _rider(current: null, fallback: true);
      final request = _request(id: 'fallback', latitude: 8.49);

      expect(fallback.usesRegisteredLocationEstimate, isTrue);
      expect(
        riderRequestRejection(request, fallback, requireCurrentGps: false),
        isNull,
      );
      expect(
        riderRequestRejection(request, fallback),
        RiderRequestRejection.locationUnavailable,
      );
    },
  );

  test(
    'server-side acceptance rejects pickup outside current GPS radius',
    () async {
      final repository = InMemoryRiderDeliveryRepository(
        requests: [_request(id: 'server-outside', latitude: 8.54)],
        riderStates: [_acceptanceRider()],
        clock: () => _now,
      );

      await expectLater(
        repository.acceptDelivery(
          const DeliveryAcceptanceCommand(
            requestId: 'server-outside',
            riderId: 'rider-a',
            idempotencyKey: 'location-correction',
          ),
        ),
        throwsA(
          isA<DeliveryAcceptanceException>().having(
            (error) => error.failure,
            'failure',
            DeliveryAcceptanceFailure.serviceAreaMismatch,
          ),
        ),
      );
    },
  );
}

final _now = DateTime(2031, 1, 1, 8);

RiderMatchingContext _rider({
  RiderDeliverySearch? current = const RiderDeliverySearch(
    latitude: 8.49,
    longitude: 124.65,
  ),
  bool fallback = false,
}) => RiderMatchingContext(
  riderId: 'rider-a',
  availability: RiderAvailability.onlineAvailable,
  vehicleType: RiderVehicleType.motorcycle,
  activeDeliveryCount: 0,
  capacityKg: 100,
  serviceArea: 'Cagayan de Oro',
  serviceRadiusKm: 3,
  registeredLatitude: 8.48,
  registeredLongitude: 124.65,
  location: current,
  gpsAccuracyMeters: current == null ? null : 5,
  allowRegisteredLocationEstimate: fallback,
);

RiderAcceptanceState _acceptanceRider() => RiderAcceptanceState(
  riderId: 'rider-a',
  isAllowedToDeliver: true,
  availability: RiderAvailability.onlineAvailable,
  vehicleType: RiderVehicleType.motorcycle,
  activeDeliveryCount: 0,
  capacityKg: 100,
  serviceArea: 'Cagayan de Oro',
  serviceRadiusKm: 3,
  registeredLatitude: 8.48,
  registeredLongitude: 124.65,
  location: const RiderDeliverySearch(
    latitude: 8.49,
    longitude: 124.65,
    radiusKm: 3,
  ),
  gpsAccuracyMeters: 5,
);

DeliveryRequest _request({required String id, required double latitude}) =>
    DeliveryRequest(
      id: id,
      orderNumber: 'AGR-$id',
      productName: 'Tomatoes',
      sellerName: 'Farm',
      buyerName: 'Buyer',
      pickupLocation: DeliveryLocation(
        address: 'Cagayan de Oro',
        latitude: latitude,
        longitude: 124.65,
      ),
      deliveryLocation: const DeliveryLocation(address: 'Buyer address'),
      pickupDeadline: _now.add(const Duration(hours: 3)),
      deliveryDeadline: _now.add(const Duration(hours: 5)),
      expiresAt: _now.add(const Duration(hours: 2)),
      serviceArea: 'Cagayan de Oro',
      totalWeightKg: 10,
      distanceKm: 2,
      estimatedTravelMinutes: 10,
      pickupToDeliveryDistanceKm: 4,
      pickupToDeliveryMinutes: 20,
      requiredVehicleTypes: const {RiderVehicleType.motorcycle},
    );
