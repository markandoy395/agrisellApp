import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/tracking/domain/delivery_tracking_models.dart';
import 'package:agresell_app/features/shared/tracking/presentation/utils/delivery_map_geometry.dart';
import 'package:agresell_app/features/shared/tracking/presentation/widgets/delivery_live_map.dart';
import 'package:agresell_app/features/shared/tracking/presentation/widgets/delivery_map_controls.dart';
import 'package:agresell_app/features/shared/tracking/presentation/widgets/delivery_map_markers.dart';
import 'package:agresell_app/features/shared/tracking/presentation/widgets/delivery_map_overlays.dart';

const _empty = DeliveryTrackingSnapshot(
  orderId: 'map-test',
  status: PlacedOrderStatus.shipping,
  gpsState: DeliveryGpsState.noLocation,
);
const _pickup = DeliveryTrackingPoint(
  name: 'Farm',
  latitude: 8.4,
  longitude: 124.6,
);
const _destination = DeliveryTrackingPoint(
  name: 'Buyer',
  latitude: 8.5,
  longitude: 124.7,
);

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  test('center prioritizes rider, destination, pickup, then fallback', () {
    expect(deliveryMapCenter(_empty), const LatLng(8.48, 124.65));
    final pickup = _empty.copyWith(pickup: _pickup);
    expect(deliveryMapCenter(pickup), _pickup.latLng);
    final stops = pickup.copyWith(destination: _destination);
    expect(deliveryMapCenter(stops), _destination.latLng);
    expect(
      deliveryMapCenter(
        stops.copyWith(riderLatitude: 8.45, riderLongitude: 124.65),
      ),
      const LatLng(8.45, 124.65),
    );
    expect(
      deliveryMapCenter(
        stops.copyWith(riderLatitude: 100, riderLongitude: 124.65),
      ),
      _destination.latLng,
    );
  });

  test('fit uses stops and rider before route-only geometry', () {
    const route = [LatLng(8.41, 124.61), LatLng(8.49, 124.69)];
    expect(deliveryMapFitPoints(_empty), isEmpty);
    expect(
      deliveryMapFitPoints(_empty.copyWith(routeCoordinates: route)),
      route,
    );
    expect(
      deliveryMapFitPoints(
        _empty.copyWith(pickup: _pickup, routeCoordinates: route),
      ),
      [_pickup.latLng],
    );
    final snapshot = _empty.copyWith(
      pickup: _pickup,
      destination: _destination,
      riderLatitude: 8.45,
      riderLongitude: 124.65,
      routeCoordinates: route,
    );
    expect(deliveryMapFitPoints(snapshot), [
      snapshot.riderLatLng,
      _pickup.latLng,
      _destination.latLng,
    ]);
  });

  testWidgets(
    'stop markers retain labels and tooltips and omit invalid rider',
    (tester) async {
      final markers = buildDeliveryMapMarkers(
        _empty.copyWith(
          pickup: _pickup,
          destination: _destination,
          riderLatitude: 100,
          riderLongitude: 124.65,
        ),
      );
      expect(markers.map((marker) => marker.point), [
        _pickup.latLng,
        _destination.latLng,
      ]);
      expect(
        markers.every((marker) => marker.width == 44 && marker.height == 44),
        isTrue,
      );
      await tester.pumpWidget(
        _host(
          Row(
            children: [
              for (final marker in markers)
                SizedBox(
                  width: marker.width,
                  height: marker.height,
                  child: marker.child,
                ),
            ],
          ),
        ),
      );
      expect(find.text('P'), findsOneWidget);
      expect(find.text('D'), findsOneWidget);
      expect(find.byTooltip('Pickup: Farm'), findsOneWidget);
      expect(find.byTooltip('Destination: Buyer'), findsOneWidget);
    },
  );

  testWidgets('controls invoke callbacks and disable refresh while loading', (
    tester,
  ) async {
    var fits = 0;
    var refreshes = 0;
    bool? following;
    Widget controls({bool loading = false, bool hasRider = true}) => _host(
      DeliveryMapControls(
        onFitRoute: () => fits++,
        hasRiderCoordinates: hasRider,
        followRider: false,
        isRefreshing: loading,
        onToggleFollowRider: (value) => following = value,
        onRefresh: () => refreshes++,
      ),
    );
    await tester.pumpWidget(controls());
    await tester.tap(find.byIcon(Icons.route_rounded));
    await tester.tap(find.byIcon(Icons.location_searching_rounded));
    await tester.tap(find.byIcon(Icons.refresh_rounded));
    expect(fits, 1);
    expect(following, isTrue);
    expect(refreshes, 1);
    await tester.pumpWidget(controls(loading: true, hasRider: false));
    expect(find.byIcon(Icons.location_searching_rounded), findsNothing);
    expect(find.byIcon(Icons.refresh_rounded), findsNothing);
    await tester.tap(find.byType(CircularProgressIndicator));
    expect(refreshes, 1);
  });

  testWidgets('details show speed and distance only when available', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        DeliveryMapDetailsOverlay(snapshot: _empty.copyWith(speedKph: 0.5)),
      ),
    );
    expect(find.text('No location'), findsOneWidget);
    expect(find.byIcon(Icons.speed_rounded), findsNothing);
    final moving = _empty.copyWith(
      gpsState: DeliveryGpsState.recent,
      speedKph: 25,
      distanceKm: 3.2,
      estimatedTravelMinutes: 12,
    );
    await tester.pumpWidget(_host(DeliveryMapDetailsOverlay(snapshot: moving)));
    expect(find.text('Recent location'), findsOneWidget);
    expect(find.text(moving.speedText), findsOneWidget);
    expect(find.text(moving.distanceText), findsOneWidget);
    expect(find.text(moving.arrivalWindowText), findsOneWidget);
  });

  testWidgets('fits once and follows rider updates without changing zoom', (
    tester,
  ) async {
    final initial = _empty.copyWith(
      riderLatitude: 8.45,
      riderLongitude: 124.65,
    );
    Widget map(DeliveryTrackingSnapshot snapshot, {bool follow = false}) =>
        _host(DeliveryLiveMap(snapshot: snapshot, followRider: follow));
    await tester.pumpWidget(map(initial));
    await tester.pump();
    final controller = tester
        .widget<FlutterMap>(find.byType(FlutterMap))
        .mapController!;
    expect(controller.camera.center.latitude, closeTo(8.45, 0.000001));
    expect(controller.camera.zoom, 15);
    controller.move(const LatLng(8.46, 124.66), 16);
    final updated = initial.copyWith(
      riderLatitude: 8.47,
      riderLongitude: 124.67,
    );
    await tester.pumpWidget(map(updated));
    expect(controller.camera.center.latitude, closeTo(8.46, 0.000001));
    await tester.pumpWidget(map(updated, follow: true));
    expect(controller.camera.center.latitude, closeTo(8.47, 0.000001));
    expect(controller.camera.center.longitude, closeTo(124.67, 0.000001));
    expect(controller.camera.zoom, 16);
    await tester.tap(find.byIcon(Icons.route_rounded));
    await tester.pump();
    expect(controller.camera.zoom, 15);
  });

  testWidgets('hides optional overlays but keeps stale GPS warning', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        DeliveryLiveMap(
          snapshot: _empty.copyWith(gpsState: DeliveryGpsState.stale),
          showControls: false,
          showDetailsOverlay: false,
        ),
      ),
    );
    expect(find.byType(DeliveryMapControls), findsNothing);
    expect(find.byType(DeliveryMapDetailsOverlay), findsNothing);
    expect(find.byType(DeliveryStaleGpsWarning), findsOneWidget);
  });
}
