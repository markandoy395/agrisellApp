import 'package:agresell_app/features/rider/deliveries/data/rider_route_cache.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_routing_service.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_route.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_route_plan.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_location_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_route_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('small GPS movements do not request duplicate routes', () async {
    final service = _RoutingService();
    final controller = RiderRouteController(
      service: service,
      cache: _MemoryRouteCache(),
    );
    addTearDown(controller.dispose);

    await controller.synchronize(
      location: _location(8.4800, 124.6500),
      requests: [_request()],
      navigationActive: true,
    );
    await controller.synchronize(
      location: _location(8.4803, 124.6500),
      requests: [_request()],
      navigationActive: true,
    );

    expect(service.calls, 1);
    expect(controller.activeRoute?.points, hasLength(3));
  });

  test('moving significantly off route recalculates once', () async {
    final service = _RoutingService();
    final controller = RiderRouteController(
      service: service,
      cache: _MemoryRouteCache(),
    );
    addTearDown(controller.dispose);
    await controller.synchronize(
      location: _location(8.4800, 124.6500),
      requests: [_request()],
      navigationActive: true,
    );

    await controller.synchronize(
      location: _location(8.4810, 124.6520),
      requests: [_request()],
      navigationActive: true,
    );

    expect(service.calls, 2);
  });

  test('cached route remains visible when refresh fails', () async {
    final cached = _plan(
      origin: const DeliveryRoutePoint(latitude: 8.48, longitude: 124.65),
      destination: const DeliveryRoutePoint(latitude: 8.49, longitude: 124.65),
    );
    final cache = _MemoryRouteCache(
      stored: CachedRiderRoutes(routes: [cached], selectedIndex: 0),
    );
    final service = _RoutingService(shouldFail: true);
    final controller = RiderRouteController(service: service, cache: cache);
    addTearDown(controller.dispose);

    await controller.restore();
    await controller.synchronize(
      location: _location(8.481, 124.65),
      requests: [_request()],
      navigationActive: true,
    );

    expect(controller.state, RiderRouteState.stale);
    expect(controller.activeRoute?.id, cached.id);
  });

  test('rider marker snaps to a nearby route but not a distant one', () async {
    final controller = RiderRouteController(
      service: _RoutingService(),
      cache: _MemoryRouteCache(),
    );
    addTearDown(controller.dispose);
    await controller.synchronize(
      location: _location(8.48, 124.65),
      requests: [_request()],
      navigationActive: true,
    );

    final near = controller.displayPoint(_location(8.485, 124.6501));
    final far = controller.displayPoint(_location(8.485, 124.652));

    expect(near.longitude, closeTo(124.65, 0.00001));
    expect(far.longitude, closeTo(124.652, 0.00001));
  });
}

class _RoutingService implements RiderRoutingService {
  _RoutingService({this.shouldFail = false});
  final bool shouldFail;
  var calls = 0;

  @override
  Future<List<RiderRoutePlan>> findRoutes({
    required String requestId,
    required String destinationKey,
    required DeliveryRoutePoint origin,
    required DeliveryRoutePoint destination,
  }) async {
    calls++;
    if (shouldFail) throw const RiderRoutingException('Offline');
    return [_plan(origin: origin, destination: destination)];
  }
}

class _MemoryRouteCache extends RiderRouteCache {
  _MemoryRouteCache({this.stored});
  CachedRiderRoutes? stored;

  @override
  Future<CachedRiderRoutes?> load() async => stored;

  @override
  Future<void> save(List<RiderRoutePlan> routes, int selectedIndex) async {
    stored = CachedRiderRoutes(routes: routes, selectedIndex: selectedIndex);
  }
}

RiderRoutePlan _plan({
  required DeliveryRoutePoint origin,
  required DeliveryRoutePoint destination,
}) => RiderRoutePlan(
  id: 'route-1',
  requestId: 'request-1',
  destinationKey: 'request-1:pickup',
  preference: RiderRoutePreference.fastest,
  distanceKm: 1.2,
  estimatedTravelMinutes: 5,
  snappedOrigin: origin,
  snappedDestination: destination,
  originRoadName: 'Main Road',
  destinationRoadName: 'Pickup Road',
  calculatedAt: DateTime(2026),
  points: [
    origin,
    DeliveryRoutePoint(
      latitude: (origin.latitude + destination.latitude) / 2,
      longitude: (origin.longitude + destination.longitude) / 2,
    ),
    destination,
  ],
);

RiderDeviceLocation _location(double latitude, double longitude) =>
    RiderDeviceLocation(
      latitude: latitude,
      longitude: longitude,
      accuracyMeters: 8,
      timestamp: DateTime(2026),
    );

DeliveryRequest _request() => DeliveryRequest(
  id: 'request-1',
  orderNumber: 'ORDER-1',
  productName: 'Vegetables',
  sellerName: 'Farmer',
  buyerName: 'Buyer',
  pickupLocation: const DeliveryLocation(
    address: 'Pickup',
    latitude: 8.49,
    longitude: 124.65,
  ),
  deliveryLocation: const DeliveryLocation(address: 'Drop-off'),
  pickupDeadline: DateTime(2026, 7, 13),
);
