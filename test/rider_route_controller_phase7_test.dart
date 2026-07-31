import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_route_plan.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_route_controller.dart';
import 'support/rider_route_phase7_fakes.dart';

void main() {
  test('route switches from pickup to buyer after successful pickup', () async {
    final service = Phase7RoutingService();
    final controller = RiderRouteController(
      service: service,
      cache: MemoryPhase7RouteCache(),
    );
    addTearDown(controller.dispose);

    await controller.synchronize(
      location: phase7Location(),
      requests: [phase7Request(DeliveryStage.goingToPickup)],
      navigationActive: true,
    );
    await controller.synchronize(
      location: phase7Location(),
      requests: [phase7Request(DeliveryStage.pickedUp)],
      navigationActive: true,
    );

    expect(service.destinationKeys, [
      'delivery-1:pickup',
      'delivery-1:delivery',
    ]);
    expect(controller.activeRoute?.destinationKey, 'delivery-1:delivery');
  });

  test(
    'manual refresh requests one new route and offline suppresses calls',
    () async {
      final service = Phase7RoutingService();
      final controller = RiderRouteController(
        service: service,
        cache: MemoryPhase7RouteCache(),
      );
      addTearDown(controller.dispose);
      final requests = [phase7Request(DeliveryStage.goingToPickup)];
      await controller.synchronize(
        location: phase7Location(),
        requests: requests,
        navigationActive: true,
      );

      await controller.refreshRoute(
        location: phase7Location(),
        requests: requests,
      );
      controller.setConnectivity(false);
      await controller.refreshRoute(
        location: phase7Location(),
        requests: requests,
      );

      expect(service.destinationKeys, hasLength(2));
      expect(controller.state, RiderRouteState.stale);
    },
  );

  test(
    'stale pickup response cannot replace newer buyer destination',
    () async {
      final service = ControlledPhase7RoutingService();
      final controller = RiderRouteController(
        service: service,
        cache: MemoryPhase7RouteCache(),
      );
      addTearDown(controller.dispose);

      final first = controller.synchronize(
        location: phase7Location(),
        requests: [phase7Request(DeliveryStage.goingToPickup)],
        navigationActive: true,
      );
      await waitForPhase7(() => service.calls.length == 1);
      final second = controller.synchronize(
        location: phase7Location(),
        requests: [phase7Request(DeliveryStage.pickedUp)],
        navigationActive: true,
      );
      service.calls[0].complete([phase7Plan('delivery-1:pickup')]);
      await waitForPhase7(() => service.calls.length == 2);
      expect(controller.activeRoute, isNull);
      service.calls[1].complete([phase7Plan('delivery-1:delivery')]);
      await Future.wait([first, second]);

      expect(controller.activeRoute?.destinationKey, 'delivery-1:delivery');
    },
  );

  test('alternative route selection is retained in the latest cache', () async {
    final cache = MemoryPhase7RouteCache();
    final service = Phase7RoutingService(includeAlternative: true);
    final controller = RiderRouteController(service: service, cache: cache);
    addTearDown(controller.dispose);
    await controller.synchronize(
      location: phase7Location(),
      requests: [phase7Request(DeliveryStage.goingToPickup)],
      navigationActive: true,
    );

    controller.selectRoute(1);

    expect(
      controller.activeRoute?.preference,
      RiderRoutePreference.alternative,
    );
    expect(cache.stored?.selectedIndex, 1);
  });

  test('terminal delivery clears the active route and latest cache', () async {
    final cache = MemoryPhase7RouteCache();
    final controller = RiderRouteController(
      service: Phase7RoutingService(),
      cache: cache,
    );
    addTearDown(controller.dispose);
    await controller.synchronize(
      location: phase7Location(),
      requests: [phase7Request(DeliveryStage.goingToDelivery)],
      navigationActive: true,
    );

    await controller.synchronize(
      location: phase7Location(),
      requests: [phase7Request(DeliveryStage.completed)],
      navigationActive: true,
    );

    expect(controller.activeRoute, isNull);
    expect(controller.selectedRequestId, isNull);
    expect(cache.cleared, isTrue);
  });
}
