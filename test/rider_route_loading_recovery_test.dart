import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agresell_app/features/shared/routing/domain/delivery_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_route_plan.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_route_cache.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_route_controller.dart';
import 'support/rider_route_phase7_fakes.dart';
import 'support/rider_availability_fakes.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_route_loading.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_routing_service.dart';

void main() {
  testWidgets('a route failure replaces loading with an enabled Retry action', (
    tester,
  ) async {
    final controller = RiderRouteController(
      service: _FailingService(),
      cache: MemoryPhase7RouteCache(),
    );
    final location = FakeRiderLocationController();
    addTearDown(controller.dispose);
    addTearDown(location.dispose);
    final requests = [phase7Request(DeliveryStage.goingToPickup)];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedBuilder(
            animation: controller,
            builder: (context, _) => RiderMapRouteLoading(
              controller: controller,
              locationController: location,
              requests: requests,
            ),
          ),
        ),
      ),
    );
    await controller.synchronize(
      location: phase7Location(),
      requests: requests,
      navigationActive: true,
    );
    await tester.pump();
    expect(find.text('Finding route...'), findsNothing);
    expect(find.text('Route unavailable'), findsOneWidget);
    expect(
      tester.widget<TextButton>(find.byType(TextButton)).onPressed,
      isNotNull,
    );
    expect(tester.takeException(), isNull);
  });
  test(
    'hung routing times out, GPS does not loop retries, explicit retry recovers',
    () async {
      final service = ControlledPhase7RoutingService();
      final controller = RiderRouteController(
        service: service,
        cache: MemoryPhase7RouteCache(),
        requestTimeout: const Duration(milliseconds: 50),
      );
      addTearDown(controller.dispose);
      final requests = [phase7Request(DeliveryStage.goingToPickup)];
      await controller.synchronize(
        location: phase7Location(),
        requests: requests,
        navigationActive: true,
      );
      expect(controller.state, RiderRouteState.error);
      expect(controller.errorMessage, contains('timed out'));
      expect(controller.canRefresh, isTrue);
      for (var index = 0; index < 5; index++) {
        await controller.synchronize(
          location: phase7Location(),
          requests: requests,
          navigationActive: true,
        );
      }
      expect(service.calls, hasLength(1));
      final retry = controller.refreshRoute(
        location: phase7Location(),
        requests: requests,
      );
      await waitForPhase7(() => service.calls.length == 2);
      service.calls[1].complete([phase7Plan('delivery-1:pickup')]);
      await retry;
      service.calls[0].complete([phase7Plan('old-route')]);
      await Future<void>.delayed(Duration.zero);
      expect(controller.state, RiderRouteState.ready);
      expect(controller.activeRoute?.destinationKey, 'delivery-1:pickup');
    },
  );

  test('a slow disk save does not delay showing the road route', () async {
    final cache = _SlowCache();
    final controller = RiderRouteController(
      service: Phase7RoutingService(),
      cache: cache,
    );
    addTearDown(controller.dispose);
    var routeShown = false;
    controller.addListener(
      () => routeShown = controller.state == RiderRouteState.ready,
    );
    await controller.synchronize(
      location: phase7Location(),
      requests: [phase7Request(DeliveryStage.goingToPickup)],
      navigationActive: true,
    );
    expect(cache.saveGate.isCompleted, isFalse);
    expect(routeShown, isTrue);
    expect(controller.canRefresh, isTrue);
    cache.saveGate.complete();
  });

  test(
    'late cache restore cannot overwrite a newly calculated route',
    () async {
      final cache = _SlowCache();
      final controller = RiderRouteController(
        service: Phase7RoutingService(),
        cache: cache,
      );
      addTearDown(controller.dispose);
      final restore = controller.restore();
      await controller.synchronize(
        location: phase7Location(),
        requests: [phase7Request(DeliveryStage.goingToPickup)],
        navigationActive: true,
      );
      cache.loadGate.complete(
        CachedRiderRoutes(routes: [phase7Plan('old-route')], selectedIndex: 0),
      );
      await restore;
      expect(controller.activeRoute?.destinationKey, 'delivery-1:pickup');
      cache.saveGate.complete();
    },
  );

  test('late network response after disposal is ignored', () async {
    final service = ControlledPhase7RoutingService();
    final controller = RiderRouteController(
      service: service,
      cache: MemoryPhase7RouteCache(),
    );
    final pending = controller.synchronize(
      location: phase7Location(),
      requests: [phase7Request(DeliveryStage.goingToPickup)],
      navigationActive: true,
    );
    await waitForPhase7(() => service.calls.isNotEmpty);
    controller.dispose();
    service.calls.first.complete([phase7Plan('delivery-1:pickup')]);
    await pending;
    expect(controller.activeRoute, isNull);
  });
}

class _FailingService extends Phase7RoutingService {
  @override
  Future<List<RiderRoutePlan>> findRoutes({
    required String requestId,
    required String destinationKey,
    required DeliveryRoutePoint origin,
    required DeliveryRoutePoint destination,
  }) async =>
      throw const RiderRoutingException('Road routing service is unavailable.');
}

class _SlowCache extends RiderRouteCache {
  final saveGate = Completer<void>();
  final loadGate = Completer<CachedRiderRoutes?>();
  @override
  Future<void> save(List<RiderRoutePlan> routes, int selectedIndex) =>
      saveGate.future;
  @override
  Future<CachedRiderRoutes?> load() => loadGate.future;
}
