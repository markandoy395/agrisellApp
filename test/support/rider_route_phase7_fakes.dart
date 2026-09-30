import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/deliveries/data/rider_route_cache.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_routing_service.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/shared/routing/domain/delivery_route.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_route_plan.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_location_controller.dart';

class Phase7RoutingService implements RiderRoutingService {
  Phase7RoutingService({this.includeAlternative = false});
  final bool includeAlternative;
  final destinationKeys = <String>[];

  @override
  Future<List<RiderRoutePlan>> findRoutes({
    required String requestId,
    required String destinationKey,
    required DeliveryRoutePoint origin,
    required DeliveryRoutePoint destination,
  }) async {
    destinationKeys.add(destinationKey);
    return [
      phase7Plan(destinationKey),
      if (includeAlternative)
        phase7Plan(
          destinationKey,
          preference: RiderRoutePreference.alternative,
        ),
    ];
  }
}

class ControlledPhase7RoutingService implements RiderRoutingService {
  final calls = <Completer<List<RiderRoutePlan>>>[];

  @override
  Future<List<RiderRoutePlan>> findRoutes({
    required String requestId,
    required String destinationKey,
    required DeliveryRoutePoint origin,
    required DeliveryRoutePoint destination,
  }) {
    final completer = Completer<List<RiderRoutePlan>>();
    calls.add(completer);
    return completer.future;
  }
}

class MemoryPhase7RouteCache extends RiderRouteCache {
  CachedRiderRoutes? stored;
  bool cleared = false;

  @override
  Future<CachedRiderRoutes?> load() async => stored;

  @override
  Future<void> save(List<RiderRoutePlan> routes, int selectedIndex) async {
    stored = CachedRiderRoutes(routes: routes, selectedIndex: selectedIndex);
    cleared = false;
  }

  @override
  Future<void> clear() async {
    stored = null;
    cleared = true;
  }
}

Future<void> waitForPhase7(bool Function() condition) async {
  for (var index = 0; index < 20 && !condition(); index++) {
    await Future<void>.delayed(Duration.zero);
  }
  expect(condition(), isTrue);
}

RiderRoutePlan phase7Plan(
  String key, {
  RiderRoutePreference preference = RiderRoutePreference.fastest,
}) => RiderRoutePlan(
  id: '$key-${preference.name}',
  requestId: 'delivery-1',
  destinationKey: key,
  preference: preference,
  distanceKm: 1,
  estimatedTravelMinutes: 5,
  snappedOrigin: const DeliveryRoutePoint(latitude: 8.48, longitude: 124.65),
  snappedDestination: const DeliveryRoutePoint(
    latitude: 8.49,
    longitude: 124.66,
  ),
  originRoadName: 'Origin Road',
  destinationRoadName: 'Destination Road',
  calculatedAt: DateTime.now(),
  points: const [
    DeliveryRoutePoint(latitude: 8.48, longitude: 124.65),
    DeliveryRoutePoint(latitude: 8.49, longitude: 124.66),
  ],
);

RiderDeviceLocation phase7Location() => RiderDeviceLocation(
  latitude: 8.48,
  longitude: 124.65,
  accuracyMeters: 8,
  timestamp: DateTime.now(),
);

DeliveryRequest phase7Request(DeliveryStage stage) => DeliveryRequest(
  id: 'delivery-1',
  orderNumber: 'ORDER-1',
  productName: 'Produce',
  sellerName: 'Farmer',
  buyerName: 'Buyer',
  pickupLocation: const DeliveryLocation(
    address: 'Farm',
    latitude: 8.49,
    longitude: 124.66,
  ),
  deliveryLocation: const DeliveryLocation(
    address: 'Buyer',
    latitude: 8.50,
    longitude: 124.67,
  ),
  pickupDeadline: DateTime(2030),
  stage: stage,
  assignedRiderId: 'rider-1',
);
