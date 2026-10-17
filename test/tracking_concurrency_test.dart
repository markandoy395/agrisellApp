import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/features/shared/routing/data/cached_delivery_route_service.dart';
import 'package:agresell_app/features/shared/routing/domain/delivery_route.dart';
import 'package:agresell_app/features/shared/routing/domain/delivery_route_service.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/tracking/data/delivery_tracking_service.dart';
import 'package:agresell_app/features/shared/tracking/domain/delivery_tracking_models.dart';
import 'package:agresell_app/features/shared/tracking/presentation/controllers/delivery_tracking_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const origin = DeliveryRoutePoint(latitude: 8, longitude: 124);
  const end = DeliveryRoutePoint(latitude: 8.1, longitude: 124.1);
  final order = PlacedOrder(
    id: 'order',
    status: PlacedOrderStatus.shipping,
    placedAt: DateTime(2026),
    deliveryAddress: 'Address',
    phoneNumber: 'phone',
    items: const [],
  );

  test(
    'route requests share work and cache expires or changes destination',
    () async {
      var now = DateTime(2026);
      final delegate = ControlledRoutes();
      final service = CachedDeliveryRouteService(delegate, now: () => now);
      final first = service.findRoute(origin: origin, destination: end);
      final second = service.findRoute(origin: origin, destination: end);
      expect(delegate.calls, 1);
      delegate.pending.complete(
        DeliveryRouteInfo(distanceKm: 1, estimatedTravelMinutes: 2),
      );
      expect(await first, same(await second));
      await service.findRoute(
        origin: const DeliveryRoutePoint(latitude: 8.0001, longitude: 124),
        destination: end,
      );
      expect(delegate.calls, 1);
      now = now.add(const Duration(minutes: 3));
      await service.findRoute(origin: origin, destination: end);
      expect(delegate.calls, 2);
      await service.findRoute(origin: origin, destination: origin);
      expect(delegate.calls, 3);
    },
  );

  testWidgets('polling does not overlap and pauses while app is backgrounded', (
    tester,
  ) async {
    final service = ControlledTracking();
    final controller = DeliveryTrackingController(
      order: order,
      service: service,
      refreshInterval: const Duration(seconds: 1),
    );
    addTearDown(controller.dispose);
    controller.start();
    await tester.pump(const Duration(seconds: 3));
    expect(service.calls, 1);
    final manual = controller.refresh();
    expect(service.calls, 1);
    service.pending.complete(
      DeliveryTrackingSnapshot(
        orderId: order.id,
        status: order.status,
        gpsState: DeliveryGpsState.unassigned,
      ),
    );
    await tester.pump();
    await manual;
    controller.didChangeAppLifecycleState(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 5));
    expect(service.calls, 1);
    controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await tester.pump();
    expect(service.calls, 2);
    expect(controller.snapshot, isNotNull);
    controller.stop();
  });

  test('disposed tracking controller discards a late response', () async {
    final service = ControlledTracking();
    final controller = DeliveryTrackingController(
      order: order,
      service: service,
    );
    final request = controller.refresh();
    controller.dispose();
    service.pending.complete(
      DeliveryTrackingSnapshot(
        orderId: order.id,
        status: order.status,
        gpsState: DeliveryGpsState.unassigned,
      ),
    );
    await request;
    expect(controller.snapshot, isNull);
  });
}

class ControlledRoutes implements DeliveryRouteService {
  int calls = 0;
  final pending = Completer<DeliveryRouteInfo?>();
  @override
  Future<DeliveryRouteInfo?> findRoute({
    required DeliveryRoutePoint origin,
    required DeliveryRoutePoint destination,
  }) {
    calls++;
    return pending.future;
  }
}

class ControlledTracking extends DeliveryTrackingService {
  int calls = 0;
  final pending = Completer<DeliveryTrackingSnapshot>();
  @override
  Future<DeliveryTrackingSnapshot> fetchTracking(PlacedOrder order) {
    calls++;
    return pending.future;
  }
}
