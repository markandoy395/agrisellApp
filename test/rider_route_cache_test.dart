import 'package:agresell_app/features/rider/deliveries/data/rider_route_cache.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_map_view_cache.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_route.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_route_plan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('active route and directions persist locally', () async {
    SharedPreferences.setMockInitialValues({});
    final cache = RiderRouteCache(
      preferences: await SharedPreferences.getInstance(),
    );
    final route = RiderRoutePlan(
      id: 'route-1',
      requestId: 'request-1',
      destinationKey: 'request-1:pickup',
      preference: RiderRoutePreference.fastest,
      distanceKm: 4.2,
      estimatedTravelMinutes: 12,
      snappedOrigin: const DeliveryRoutePoint(
        latitude: 8.48,
        longitude: 124.65,
      ),
      snappedDestination: const DeliveryRoutePoint(
        latitude: 8.49,
        longitude: 124.66,
      ),
      originRoadName: 'Main Road',
      destinationRoadName: 'Market Road',
      calculatedAt: DateTime(2026, 7, 13),
      points: const [
        DeliveryRoutePoint(latitude: 8.48, longitude: 124.65),
        DeliveryRoutePoint(latitude: 8.49, longitude: 124.66),
      ],
      instructions: const [
        RiderRouteInstruction(
          text: 'Turn left onto Market Road',
          distanceMeters: 450,
          durationSeconds: 90,
        ),
      ],
    );

    await cache.save([route], 0);
    final restored = await cache.load();

    expect(restored?.routes.single.points, hasLength(2));
    expect(
      restored?.routes.single.instructions.single.text,
      contains('Market'),
    );
  });

  test('map camera target, zoom, and bearing persist locally', () async {
    SharedPreferences.setMockInitialValues({});
    final cache = RiderMapViewCache(
      preferences: await SharedPreferences.getInstance(),
    );
    const view = RiderMapView(
      latitude: 8.482,
      longitude: 124.651,
      zoom: 16.5,
      rotation: 28,
    );

    await cache.save(view);
    final restored = await cache.load();

    expect(restored?.latitude, view.latitude);
    expect(restored?.longitude, view.longitude);
    expect(restored?.zoom, view.zoom);
    expect(restored?.rotation, view.rotation);
  });
}
