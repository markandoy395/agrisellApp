import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/deliveries/data/rider_live_location_store.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_location_outbox.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/shared/routing/domain/delivery_route.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_update.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_arrival_validation.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_live_location_policy.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_location.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_location_quality.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_route_geometry.dart';
import 'support/in_memory_rider_live_location_store.dart';

void main() {
  final now = DateTime.now();
  final request = DeliveryRequest(
    id: 'map-delivery',
    orderNumber: 'MAP-1',
    productName: 'Rice',
    sellerName: 'Seller',
    buyerName: 'Buyer',
    pickupLocation: const DeliveryLocation(
      address: 'Pickup',
      latitude: 14,
      longitude: 120,
    ),
    deliveryLocation: const DeliveryLocation(
      address: 'Buyer',
      latitude: 14.01,
      longitude: 120.01,
    ),
    pickupDeadline: now.add(const Duration(hours: 2)),
    stage: DeliveryStage.goingToPickup,
    assignedRiderId: 'rider-1',
  );

  test('location metadata and quality are persisted', () {
    final location = RiderLocation(
      latitude: 14,
      longitude: 120,
      accuracyMeters: 8,
      speedMetersPerSecond: 4.5,
      headingDegrees: 90,
      isMocked: false,
      timestamp: now,
    );
    final restored = RiderLocation.fromJson(location.toJson());
    expect(restored.speedMetersPerSecond, 4.5);
    expect(restored.headingDegrees, 90);
    expect(restored.quality, RiderLocationQuality.accurate);
  });

  test('route progress and remaining distance follow road geometry', () {
    const route = [
      DeliveryRoutePoint(latitude: 14, longitude: 120),
      DeliveryRoutePoint(latitude: 14, longitude: 120.01),
      DeliveryRoutePoint(latitude: 14, longitude: 120.02),
    ];
    final progress = routeProgressFraction(
      const DeliveryRoutePoint(latitude: 14, longitude: 120.01),
      route,
    );
    expect(progress, closeTo(0.5, 0.02));
    expect(
      remainingRouteDistanceMeters(
        const DeliveryRoutePoint(latitude: 14, longitude: 120.01),
        route,
      ),
      closeTo(routePointDistanceMeters(route[1], route[2]), 2),
    );
  });

  test('arrival requires fresh accurate location within radius', () {
    final result = validateRiderArrival(
      location: DeliveryStatusLocation(
        latitude: 14,
        longitude: 120,
        accuracyMeters: 10,
        timestamp: now,
      ),
      target: request.pickupLocation,
      radiusMeters: 100,
      maxAccuracyMeters: 50,
      now: now,
    );
    expect(result.isValid, isTrue);
    final stale = validateRiderArrival(
      location: DeliveryStatusLocation(
        latitude: 14,
        longitude: 120,
        accuracyMeters: 10,
        timestamp: now.subtract(const Duration(minutes: 2)),
      ),
      target: request.pickupLocation,
      radiusMeters: 100,
      maxAccuracyMeters: 50,
      now: now,
    );
    expect(stale.isValid, isFalse);
  });

  test(
    'live location is limited to assigned rider and navigation stages',
    () async {
      final access = RiderLiveLocationAccess.authorize(
        request: request,
        riderId: 'rider-1',
        status: DeliveryStatus.goingToPickup,
      );
      expect(access.allowed, isTrue);
      expect(
        RiderLiveLocationAccess.authorize(
          request: request,
          riderId: 'other-rider',
          status: DeliveryStatus.goingToPickup,
        ).allowed,
        isFalse,
      );
      final update = RiderLocationUpdate(
        latitude: 14,
        longitude: 120,
        accuracyMeters: 10,
        capturedAt: now,
        deliveryId: request.id,
        riderId: 'rider-1',
      );
      final store = InMemoryRiderLiveLocationStore(
        participants: {
          request.id: {'buyer-1'},
        },
      );
      await store.publish(
        request: request,
        status: DeliveryStatus.goingToPickup,
        update: update,
      );
      expect(
        (await store.latest(deliveryId: request.id, participantId: 'buyer-1')),
        isNotNull,
      );
      expect(
        () => store.latest(deliveryId: request.id, participantId: 'unknown'),
        throwsA(isA<RiderLiveLocationAccessException>()),
      );
    },
  );
}
