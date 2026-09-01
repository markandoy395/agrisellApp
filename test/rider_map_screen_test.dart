import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_map_discovery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_routing_service.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_location_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_route_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/screens/rider_map_screen.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_live_map.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_content.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_route.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_nearby_farm.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_road_access.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/rider_availability_fakes.dart';
import 'support/rider_test_models.dart';

void main() {
  testWidgets('map starts device tracking only after its tab is active', (
    tester,
  ) async {
    final deliveryController = RiderDeliveryController();
    final locationController = _TrackingLocationController();
    addTearDown(deliveryController.dispose);
    addTearDown(locationController.dispose);

    await _pumpMap(
      tester,
      deliveryController: deliveryController,
      locationController: locationController,
      isActive: false,
    );

    expect(locationController.startCalls, 0);

    await _pumpMap(
      tester,
      deliveryController: deliveryController,
      locationController: locationController,
      isActive: true,
    );
    await tester.pump();

    expect(locationController.startCalls, 1);
  });

  testWidgets('full-screen map exposes discovery filters and marker types', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 700);
    final location = FakeRiderLocationController();
    final route = RiderRouteController();
    final map = MapController();
    RiderNearbyFarm? tappedFarm;
    DeliveryRequest? tappedRequest;
    RiderMapMarkerKind? tappedKind;
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
      location.dispose();
      route.dispose();
      map.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RiderMapContent(
            controller: location,
            mapController: map,
            requests: [_availableRequest(), _assignedRequest()],
            farms: const [
              RiderNearbyFarm(
                id: 'farm-without-order',
                name: 'Independent Farm',
                address: 'Independent Farm pickup',
                latitude: 8.4805,
                longitude: 124.6505,
                distanceKm: 0.1,
                mainCrops: ['Corn'],
              ),
            ],
            roadAccessConnections: const [
              RiderRoadAccessConnection(
                id: 'farm:farm-without-order',
                kind: RiderRoadAccessKind.farmer,
                sourcePoint: DeliveryRoutePoint(
                  latitude: 8.4805,
                  longitude: 124.6505,
                ),
                roadPoint: DeliveryRoutePoint(
                  latitude: 8.4807,
                  longitude: 124.6507,
                ),
                sourceLabel: 'Independent Farm',
                roadName: 'National Highway',
                distanceMeters: 31,
              ),
            ],
            farmDiscoveryError: null,
            farmsLoading: false,
            routeController: route,
            riderId: 'rider-a',
            filter: RiderMapFilter.all,
            mapZoom: 15,
            discoveryRadiusKm: 15,
            navigationActive: false,
            onFilterChanged: (_) {},
            onMarkerTap: (request, kind) {
              tappedRequest = request;
              tappedKind = kind;
            },
            onFarmTap: (farm) => tappedFarm = farm,
            onNavigateActive: (_) {},
            onExitNavigation: () {},
            onRecenter: () {},
            onRefresh: () {},
            onOpenList: () {},
            onMapReady: () {},
            onPositionChanged: (_, _) {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Rider map'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Deliveries'), findsOneWidget);
    expect(find.text('Farmers'), findsOneWidget);
    expect(find.text('Assigned'), findsOneWidget);
    expect(find.text('Nearby'), findsOneWidget);
    for (final filter in RiderMapFilter.values) {
      expect(
        find.byKey(ValueKey('rider-map-filter-${filter.name}-icon')),
        findsOneWidget,
      );
    }
    expect(find.byIcon(Icons.inventory_2_rounded), findsWidgets);
    expect(find.byIcon(Icons.agriculture_rounded), findsWidgets);
    expect(find.byIcon(Icons.local_shipping_rounded), findsWidgets);
    expect(find.byIcon(Icons.navigation_rounded), findsWidgets);
    expect(find.byType(PolylineLayer), findsOneWidget);
    final farmMarker = find.bySemanticsLabel('Farmer pickup: Independent Farm');
    final farmTransform = tester.widget<Transform>(
      find.descendant(of: farmMarker, matching: find.byType(Transform)),
    );
    expect(farmTransform.transform.getTranslation().x, 34);
    final farmTapTarget = find.descendant(
      of: farmMarker,
      matching: find.byType(GestureDetector),
    );
    expect(tester.getSize(farmTapTarget), const Size(56, 56));
    await tester.tap(farmTapTarget);
    await tester.pump();
    expect(tappedFarm?.id, 'farm-without-order');

    final deliveryTapTarget = find.descendant(
      of: find.bySemanticsLabel('Available pickup: Fresh vegetables'),
      matching: find.byType(GestureDetector),
    );
    await tester.tap(deliveryTapTarget);
    await tester.pump();
    expect(tappedRequest?.id, 'available-1');
    expect(tappedKind, RiderMapMarkerKind.availableDelivery);

    final assignedTapTarget = find.descendant(
      of: find.bySemanticsLabel('Assigned pickup: Rice Farm'),
      matching: find.byType(GestureDetector),
    );
    await tester.tap(assignedTapTarget);
    await tester.pump();
    expect(tappedRequest?.id, 'assigned-1');
    expect(tappedKind, RiderMapMarkerKind.assignedDelivery);
    expect(tester.takeException(), isNull);
  });

  testWidgets('one farm tap immediately opens actions and selects its guide', (
    tester,
  ) async {
    final delivery = RiderDeliveryController();
    final location = FakeRiderLocationController();
    final roadAccess = _FixedRoadAccessService();
    addTearDown(delivery.dispose);
    addTearDown(location.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: RiderMapScreen(
          profile: null,
          deliveryController: delivery,
          locationController: location,
          roadAccessService: roadAccess,
          mapDiscoveryRepository: const InMemoryRiderMapDiscoveryRepository(
            farms: [
              RiderNearbyFarm(
                id: 'farm-without-order',
                name: 'Independent Farm',
                address: 'Independent Farm pickup',
                latitude: 8.4805,
                longitude: 124.6505,
                distanceKm: 0.1,
              ),
            ],
          ),
          isActive: true,
          onOpenList: () {},
        ),
      ),
    );
    await tester.pump();

    final farmMarker = find.bySemanticsLabel('Farmer pickup: Independent Farm');
    expect(farmMarker, findsOneWidget);
    expect(
      find.descendant(
        of: farmMarker,
        matching: find.byIcon(Icons.agriculture_rounded),
      ),
      findsOneWidget,
    );
    expect(find.byType(PolylineLayer), findsNothing);

    final tapTarget = find.descendant(
      of: farmMarker,
      matching: find.byType(GestureDetector),
    );
    await tester.tap(tapTarget);
    await tester.pump();

    expect(find.text('Navigate to farm'), findsOneWidget);
    expect(roadAccess.calls, 0);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(roadAccess.calls, 1);
    expect(find.byType(PolylineLayer), findsOneWidget);

    Navigator.of(tester.element(find.text('Navigate to farm'))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(PolylineLayer), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('map refresh reloads farms without requiring rider movement', (
    tester,
  ) async {
    final delivery = RiderDeliveryController();
    final location = FakeRiderLocationController();
    final repository = _RefreshingFarmRepository();
    addTearDown(delivery.dispose);
    addTearDown(location.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: RiderMapScreen(
          profile: verifiedRiderProfile(),
          deliveryController: delivery,
          locationController: location,
          mapDiscoveryRepository: repository,
          isActive: true,
          onOpenList: () {},
        ),
      ),
    );
    await tester.pump();
    expect(
      find.bySemanticsLabel('Farmer pickup: Refreshed Farm'),
      findsNothing,
    );

    await tester.tap(find.byTooltip('Refresh location'));
    await tester.pump();
    await tester.pump();

    expect(repository.calls, 2);
    expect(
      find.bySemanticsLabel('Farmer pickup: Refreshed Farm'),
      findsOneWidget,
    );
  });
}

class _RefreshingFarmRepository implements RiderMapDiscoveryRepository {
  var calls = 0;

  @override
  Future<List<RiderNearbyFarm>> fetchNearbyFarms(
    RiderDeliverySearch search,
  ) async {
    calls++;
    if (calls == 1) return const [];
    return const [
      RiderNearbyFarm(
        id: 'refreshed-farm',
        name: 'Refreshed Farm',
        address: 'Current GPS location',
        latitude: 8.4801,
        longitude: 124.6501,
        distanceKm: 0.02,
      ),
    ];
  }
}

class _FixedRoadAccessService implements RiderRoadAccessService {
  var calls = 0;

  @override
  Future<RiderRoadAccessSnap?> findNearestRoadAccess(
    DeliveryRoutePoint point,
  ) async {
    calls++;
    return RiderRoadAccessSnap(
      point: DeliveryRoutePoint(
        latitude: point.latitude + 0.0002,
        longitude: point.longitude + 0.0002,
      ),
      roadName: 'National Highway',
      distanceMeters: 31,
    );
  }
}

Future<void> _pumpMap(
  WidgetTester tester, {
  required RiderDeliveryController deliveryController,
  required RiderLocationController locationController,
  required bool isActive,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: RiderMapScreen(
        key: const ValueKey('rider-map'),
        profile: null,
        deliveryController: deliveryController,
        locationController: locationController,
        isActive: isActive,
        onOpenList: () {},
      ),
    ),
  );
}

class _TrackingLocationController extends RiderLocationController {
  var startCalls = 0;

  @override
  Future<void> startTracking() async {
    startCalls++;
  }
}

DeliveryRequest _availableRequest() => DeliveryRequest(
  id: 'available-1',
  orderNumber: 'Order #1',
  productName: 'Fresh vegetables',
  sellerName: 'Green Farm',
  buyerName: 'Buyer',
  pickupLocation: const DeliveryLocation(
    address: 'Green Farm pickup',
    latitude: 8.481,
    longitude: 124.651,
  ),
  deliveryLocation: const DeliveryLocation(
    address: 'Buyer area',
    latitude: 8.49,
    longitude: 124.66,
  ),
  pickupDeadline: DateTime(2030),
);

DeliveryRequest _assignedRequest() => DeliveryRequest(
  id: 'assigned-1',
  orderNumber: 'Order #2',
  productName: 'Rice sacks',
  sellerName: 'Rice Farm',
  buyerName: 'Buyer',
  pickupLocation: const DeliveryLocation(
    address: 'Rice Farm pickup',
    latitude: 8.482,
    longitude: 124.652,
  ),
  deliveryLocation: const DeliveryLocation(
    address: 'Delivery area',
    latitude: 8.492,
    longitude: 124.662,
  ),
  pickupDeadline: DateTime(2030),
  stage: DeliveryStage.accepted,
  assignedRiderId: 'rider-a',
);
