import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request_metadata.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_request_matcher.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_request_query.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_registration.dart';

void main() {
  final now = DateTime(2030, 1, 1, 8);

  test('online available Rider and ready request are eligible', () {
    expect(riderRequestRejection(_request(now), _rider()), isNull);
  });

  test('Rider environment and active limit are authoritative inputs', () {
    expect(
      riderRequestRejection(
        _request(now),
        _rider(availability: RiderAvailability.offline),
      ),
      RiderRequestRejection.riderUnavailable,
    );
    expect(
      riderRequestRejection(_request(now), _rider(accuracy: 80)),
      RiderRequestRejection.poorGpsAccuracy,
    );
    expect(
      riderRequestRejection(_request(now), _rider(activeCount: 1)),
      RiderRequestRejection.activeDeliveryLimit,
    );
  });

  test(
    'global readiness, assignment, cancellation, and expiry are enforced',
    () {
      for (final request in [
        _request(now, stage: DeliveryStage.accepted, assignedRiderId: 'other'),
        _request(now, stage: DeliveryStage.cancelled),
        _request(now, expiresAt: now.subtract(const Duration(minutes: 1))),
        _request(
          now,
          reservedRiderId: 'other',
          reservedUntil: now.add(const Duration(minutes: 5)),
        ),
      ]) {
        expect(
          riderRequestRejection(request, _rider(), at: now),
          RiderRequestRejection.globallyUnavailable,
        );
      }
    },
  );

  test('current GPS can match requests without registered service area text', () {
    expect(
      riderRequestRejection(_request(now), _rider(serviceArea: '')),
      isNull,
    );
  });

  test('fallback service area, radius, vehicle, and capacity rules are enforced', () {
    expect(
      riderRequestRejection(
        _request(now, serviceArea: 'Iligan'),
        _rider(current: null, fallback: true),
        requireCurrentGps: false,
      ),
      RiderRequestRejection.outsideServiceArea,
    );
    expect(
      riderRequestRejection(
        _request(now, pickupDistance: 20),
        _rider(current: null, fallback: true),
        requireCurrentGps: false,
      ),
      RiderRequestRejection.outsideServiceRadius,
    );
    expect(
      riderRequestRejection(
        _request(now, vehicles: const {RiderVehicleType.van}),
        _rider(),
      ),
      RiderRequestRejection.vehicleIncompatible,
    );
    expect(
      riderRequestRejection(_request(now, weight: 151), _rider()),
      RiderRequestRejection.overweight,
    );
    expect(
      riderRequestRejection(_request(now, weight: 10), _rider(capacity: null)),
      RiderRequestRejection.capacityUnknown,
    );
  });

  test('unreachable pickup and delivery deadlines are rejected', () {
    expect(
      riderRequestRejection(
        _request(now, pickupDeadline: now.add(const Duration(minutes: 5))),
        _rider(),
        at: now,
      ),
      RiderRequestRejection.pickupDeadlineUnreachable,
    );
    expect(
      riderRequestRejection(
        _request(now, deliveryDeadline: now.add(const Duration(minutes: 20))),
        _rider(),
        at: now,
      ),
      RiderRequestRejection.deliveryDeadlineUnreachable,
    );
  });

  test('safety-critical handling requires proven vehicle capability', () {
    final request = _request(
      now,
      handling: const [
        ProductHandlingRequirement(
          type: ProductHandlingType.temperatureSensitive,
        ),
      ],
    );
    expect(
      riderRequestRejection(request, _rider()),
      RiderRequestRejection.handlingIncompatible,
    );
    expect(
      riderRequestRejection(
        request,
        _rider(capabilities: const {'temperatureSensitive'}),
      ),
      isNull,
    );
  });
}

RiderMatchingContext _rider({
  RiderAvailability availability = RiderAvailability.onlineAvailable,
  double accuracy = 5,
  int activeCount = 0,
  double? capacity = 150,
  String serviceArea = 'Cagayan de Oro',
  RiderDeliverySearch? current = const RiderDeliverySearch(
    latitude: 8.48,
    longitude: 124.65,
  ),
  bool fallback = false,
  Set<String> capabilities = const {},
}) => RiderMatchingContext(
  riderId: 'rider-a',
  availability: availability,
  vehicleType: RiderVehicleType.motorcycle,
  capacityKg: capacity,
  serviceArea: serviceArea,
  serviceRadiusKm: 15,
  registeredLatitude: 8.48,
  registeredLongitude: 124.65,
  location: current,
  gpsAccuracyMeters: current == null ? null : accuracy,
  allowRegisteredLocationEstimate: fallback,
  activeDeliveryCount: activeCount,
  handlingCapabilityKeys: capabilities,
);

DeliveryRequest _request(
  DateTime now, {
  DeliveryStage stage = DeliveryStage.readyForPickup,
  String? assignedRiderId,
  String? reservedRiderId,
  DateTime? reservedUntil,
  DateTime? expiresAt,
  String serviceArea = 'Cagayan de Oro',
  double pickupDistance = 2,
  double weight = 25,
  Set<RiderVehicleType> vehicles = const {RiderVehicleType.motorcycle},
  DateTime? pickupDeadline,
  DateTime? deliveryDeadline,
  List<ProductHandlingRequirement> handling = const [],
}) => DeliveryRequest(
  id: 'request-1',
  orderNumber: 'AGR-1',
  productName: 'Tomatoes',
  sellerName: 'Farm',
  buyerName: 'Private buyer',
  pickupLocation: DeliveryLocation(
    address: 'Carmen',
    latitude: 8.48 + pickupDistance / 111,
    longitude: 124.65,
  ),
  deliveryLocation: const DeliveryLocation(address: 'Uptown'),
  pickupDeadline: pickupDeadline ?? now.add(const Duration(minutes: 45)),
  deliveryDeadline: deliveryDeadline ?? now.add(const Duration(minutes: 120)),
  expiresAt: expiresAt ?? now.add(const Duration(minutes: 40)),
  serviceArea: serviceArea,
  totalWeightKg: weight,
  distanceKm: pickupDistance,
  estimatedTravelMinutes: 15,
  pickupToDeliveryDistanceKm: 5,
  pickupToDeliveryMinutes: 25,
  requiredVehicleTypes: vehicles,
  handlingRequirements: handling,
  stage: stage,
  assignedRiderId: assignedRiderId,
  reservedRiderId: reservedRiderId,
  reservedUntil: reservedUntil,
);
