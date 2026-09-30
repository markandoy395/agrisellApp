import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_routing_service.dart';
import 'package:agresell_app/features/shared/routing/domain/delivery_route.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_route_plan.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/routing/domain/delivery_route_service.dart';
import 'package:agresell_app/features/shared/tracking/data/delivery_tracking_service.dart';
import 'package:agresell_app/features/shared/tracking/domain/delivery_tracking_models.dart';
import 'package:agresell_app/features/shared/tracking/presentation/controllers/delivery_tracking_controller.dart';
import 'package:agresell_app/features/shared/tracking/presentation/widgets/delivery_live_map.dart';
import 'package:agresell_app/features/shared/tracking/presentation/widgets/delivery_tracking_sheet.dart';

class _FakeRiderRoutingService implements RiderRoutingService, DeliveryRouteService {
  @override
  Future<DeliveryRouteInfo?> findRoute({
    required DeliveryRoutePoint origin,
    required DeliveryRoutePoint destination,
  }) async {
    return DeliveryRouteInfo(
      distanceKm: 3.2,
      estimatedTravelMinutes: 12,
      points: [
        origin,
        DeliveryRoutePoint(
          latitude: (origin.latitude + destination.latitude) / 2,
          longitude: (origin.longitude + destination.longitude) / 2,
        ),
        destination,
      ],
    );
  }
  @override
  Future<List<RiderRoutePlan>> findRoutes({
    required String requestId,
    required String destinationKey,
    required DeliveryRoutePoint origin,
    required DeliveryRoutePoint destination,
  }) async {
    return [
      RiderRoutePlan(
        id: 'test-route',
        requestId: requestId,
        destinationKey: destinationKey,
        preference: RiderRoutePreference.fastest,
        distanceKm: 3.2,
        estimatedTravelMinutes: 12,
        snappedOrigin: origin,
        snappedDestination: destination,
        originRoadName: 'Sayre Highway',
        destinationRoadName: 'Farm Road',
        calculatedAt: DateTime.now(),
        points: [
          origin,
          DeliveryRoutePoint(
            latitude: (origin.latitude + destination.latitude) / 2,
            longitude: (origin.longitude + destination.longitude) / 2,
          ),
          destination,
        ],
      ),
    ];
  }
}

void main() {
  final testOrder = PlacedOrder(
    id: 'ORD-TEST-101',
    status: PlacedOrderStatus.shipping,
    placedAt: DateTime.now().subtract(const Duration(hours: 1)),
    deliveryAddress: 'Poblacion, Valencia City, Bukidnon',
    phoneNumber: '0917-123-4567',
    items: const [],
    deliveryLatitude: 8.4720,
    deliveryLongitude: 124.6450,
  );

  group('Delivery Tracking Domain Models', () {
    test('GPS state correctly detects recent vs stale GPS based on 120s threshold', () {
      final now = DateTime.now();

      final recentSnapshot = DeliveryTrackingSnapshot(
        orderId: 'ORD-1',
        status: PlacedOrderStatus.shipping,
        gpsState: DeliveryGpsState.recent,
        locationUpdatedAt: now.subtract(const Duration(seconds: 30)),
        speedKph: 25.0,
      );
      expect(recentSnapshot.gpsState.isLive, isTrue);
      expect(recentSnapshot.gpsState.isStale, isFalse);
      expect(recentSnapshot.speedText, '25 km/h');

      final staleSnapshot = DeliveryTrackingSnapshot(
        orderId: 'ORD-1',
        status: PlacedOrderStatus.shipping,
        gpsState: DeliveryGpsState.stale,
        locationUpdatedAt: now.subtract(const Duration(seconds: 150)),
        speedKph: 0.0,
      );
      expect(staleSnapshot.gpsState.isLive, isFalse);
      expect(staleSnapshot.gpsState.isStale, isTrue);
      expect(staleSnapshot.speedText, 'Stationary');
    });

    test('arrivalWindowText formats arrival time and estimated minutes correctly', () {
      final arrivalTime = DateTime(2026, 9, 19, 15, 45);
      final snapshot = DeliveryTrackingSnapshot(
        orderId: 'ORD-1',
        status: PlacedOrderStatus.shipping,
        gpsState: DeliveryGpsState.recent,
        estimatedTravelMinutes: 15,
        estimatedArrival: arrivalTime,
        distanceKm: 4.5,
      );

      expect(snapshot.arrivalWindowText, contains('3:45 PM'));
      expect(snapshot.arrivalWindowText, contains('~15 mins'));
      expect(snapshot.distanceText, '4.5 km');
    });
  });

  group('DeliveryTrackingService', () {
    test('fetches tracking snapshot with route, checkpoints, and rider info', () async {
      final service = DeliveryTrackingService(
        routingService: _FakeRiderRoutingService(),
      );

      final snapshot = await service.fetchTracking(testOrder);

      expect(snapshot.orderId, testOrder.id);
      expect(snapshot.status, PlacedOrderStatus.shipping);
      expect(snapshot.hasRiderCoordinates, isTrue);
      expect(snapshot.hasRoute, isTrue);
      expect(snapshot.routeCoordinates.length, 3);
      expect(snapshot.distanceKm, 3.2);
      expect(snapshot.estimatedTravelMinutes, 12);
      expect(snapshot.checkpoints.length, 6);
      expect(snapshot.checkpoints.first.isCompleted, isTrue); // Order Placed
      expect(snapshot.checkpoints[4].isActive, isTrue); // Rider In Transit
    });
  });

  group('DeliveryTrackingController', () {
    test('starts polling, fetches snapshot, and handles follow rider toggle', () async {
      final service = DeliveryTrackingService(
        routingService: _FakeRiderRoutingService(),
      );
      final controller = DeliveryTrackingController(
        order: testOrder,
        service: service,
        refreshInterval: const Duration(milliseconds: 500),
      );

      expect(controller.snapshot, isNull);
      expect(controller.followRider, isFalse);

      controller.start();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(controller.snapshot, isNotNull);
      expect(controller.snapshot!.orderId, testOrder.id);

      controller.setFollowRider(true);
      expect(controller.followRider, isTrue);

      controller.dispose();
    });
  });

  group('DeliveryLiveMap Widget', () {
    testWidgets('renders map, markers, polyline, and details overlay', (tester) async {
      final snapshot = DeliveryTrackingSnapshot(
        orderId: 'ORD-TEST',
        status: PlacedOrderStatus.shipping,
        gpsState: DeliveryGpsState.recent,
        riderLatitude: 8.4800,
        riderLongitude: 124.6500,
        speedKph: 28.0,
        riderHeading: 90.0,
        pickup: const DeliveryTrackingPoint(
          name: 'Valencia Farm',
          latitude: 8.4900,
          longitude: 124.6600,
        ),
        destination: const DeliveryTrackingPoint(
          name: 'Buyer Home',
          latitude: 8.4700,
          longitude: 124.6400,
        ),
        routeCoordinates: const [
          LatLng(8.4900, 124.6600),
          LatLng(8.4800, 124.6500),
          LatLng(8.4700, 124.6400),
        ],
        distanceKm: 3.5,
        estimatedTravelMinutes: 14,
        estimatedArrival: DateTime(2026, 9, 19, 16, 0),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            body: DeliveryLiveMap(
              snapshot: snapshot,
              height: 400,
            ),
          ),
        ),
      );

      expect(find.byType(DeliveryLiveMap), findsOneWidget);
      expect(find.text('Recent location'), findsOneWidget);
      expect(find.text('28 km/h'), findsOneWidget);
      expect(find.textContaining('~14 mins'), findsOneWidget);
      expect(find.text('3.5 km'), findsOneWidget);
    });

    testWidgets('shows stale GPS warning when location is stale', (tester) async {
      final snapshot = DeliveryTrackingSnapshot(
        orderId: 'ORD-TEST',
        status: PlacedOrderStatus.shipping,
        gpsState: DeliveryGpsState.stale,
        riderLatitude: 8.4800,
        riderLongitude: 124.6500,
        speedKph: 0.0,
        estimatedTravelMinutes: 15,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            body: DeliveryLiveMap(
              snapshot: snapshot,
              height: 400,
            ),
          ),
        ),
      );

      expect(find.text('Stale location'), findsOneWidget);
      expect(
        find.textContaining('Stale GPS: Rider location was last updated >2 minutes ago.'),
        findsOneWidget,
      );
    });
  });

  group('DeliveryTrackingSheet Widget', () {
    testWidgets('renders rider info, speed, and checkpoint timeline', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final service = DeliveryTrackingService(
        routingService: _FakeRiderRoutingService(),
      );
      final controller = DeliveryTrackingController(
        order: testOrder,
        service: service,
        refreshInterval: const Duration(hours: 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            body: DeliveryTrackingSheet(
              order: testOrder,
              controller: controller,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Live GPS & Route Tracking'), findsOneWidget);
      expect(find.text('Delivery Checkpoints'), findsOneWidget);
      expect(find.text('Order Placed'), findsOneWidget);
      expect(find.text('Rider In Transit'), findsOneWidget);
      expect(find.text('Delivered'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    });
  });
}
