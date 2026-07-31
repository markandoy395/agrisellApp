import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/dashboard/domain/rider_dashboard_state.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_dashboard_controller.dart';

import 'support/rider_dashboard_fakes.dart';

void main() {
  test('dashboard exposes initial loading then empty ready data', () async {
    final gate = Completer<void>();
    final repository = FakeRiderDashboardRepository(gate: gate);
    final controller = RiderDashboardController(repository: repository);
    addTearDown(controller.dispose);

    final request = controller.load(riderId: 'rider-a');
    expect(controller.state, RiderDashboardLoadState.initialLoading);
    gate.complete();
    await request;

    expect(controller.state, RiderDashboardLoadState.ready);
    expect(controller.metrics.todayCompletedDeliveries, 0);
    expect(controller.hasCachedData, isTrue);
  });

  test('duplicate and fresh-cache loads do not refetch dashboard', () async {
    final gate = Completer<void>();
    final repository = FakeRiderDashboardRepository(gate: gate);
    final controller = RiderDashboardController(repository: repository);
    addTearDown(controller.dispose);

    final first = controller.load(riderId: 'rider-a');
    final duplicate = controller.load(riderId: 'rider-a');
    expect(repository.fetchCalls, 1);
    gate.complete();
    await Future.wait([first, duplicate]);
    await controller.load(riderId: 'rider-a');

    expect(repository.fetchCalls, 1);
  });

  test('server failure exposes safe error and Retry state', () async {
    final repository = FakeRiderDashboardRepository(shouldFail: true);
    final controller = RiderDashboardController(repository: repository);
    addTearDown(controller.dispose);

    await controller.load(riderId: 'rider-a');

    expect(controller.state, RiderDashboardLoadState.serverError);
    expect(controller.errorMessage, 'The Rider dashboard could not be loaded.');
  });

  test('cached metrics remain visible when refresh fails', () async {
    final cache = FakeRiderDashboardCache()
      ..data = backendDashboardData(
        metrics: const RiderDashboardMetrics(
          todayCompletedDeliveries: 4,
          unreadMessageCount: 2,
        ),
      );
    final repository = FakeRiderDashboardRepository(shouldFail: true);
    final controller = RiderDashboardController(
      repository: repository,
      cache: cache,
    );
    addTearDown(controller.dispose);

    await controller.load(riderId: 'rider-a');

    expect(controller.state, RiderDashboardLoadState.partialData);
    expect(controller.metrics.todayCompletedDeliveries, 4);
    expect(controller.metrics.unreadMessageCount, 2);
    expect(controller.hasCachedData, isTrue);
  });

  test('manual refresh preserves data and writes the latest cache', () async {
    final repository = FakeRiderDashboardRepository(
      data: backendDashboardData(
        metrics: const RiderDashboardMetrics(todayCompletedDeliveries: 1),
      ),
    );
    final cache = FakeRiderDashboardCache();
    final controller = RiderDashboardController(
      repository: repository,
      cache: cache,
    );
    addTearDown(controller.dispose);
    await controller.load(riderId: 'rider-a');
    repository.data = backendDashboardData(
      metrics: const RiderDashboardMetrics(todayCompletedDeliveries: 2),
    );

    final refresh = controller.refresh();
    expect(controller.state, RiderDashboardLoadState.refreshing);
    expect(controller.metrics.todayCompletedDeliveries, 1);
    await refresh;

    expect(controller.metrics.todayCompletedDeliveries, 2);
    expect(repository.fetchCalls, 2);
    expect(cache.saveCalls, 2);
  });

  test('outdated Rider result is ignored and new Rider is loaded', () async {
    final gate = Completer<void>();
    final repository = FakeRiderDashboardRepository(gate: gate);
    final controller = RiderDashboardController(repository: repository);
    addTearDown(controller.dispose);

    final oldRequest = controller.load(riderId: 'rider-a');
    final newRequest = controller.load(riderId: 'rider-b');
    gate.complete();
    await Future.wait([oldRequest, newRequest]);

    expect(repository.requestedRiders, ['rider-a', 'rider-b']);
    expect(controller.state, RiderDashboardLoadState.ready);
  });

  test('local successful completion updates today count', () async {
    final controller = RiderDashboardController(
      repository: FakeRiderDashboardRepository(),
    );
    addTearDown(controller.dispose);
    await controller.load(riderId: 'rider-a');

    controller.applyLocalCompletedToday(1);

    expect(controller.metrics.todayCompletedDeliveries, 1);
    expect(controller.sectionUnavailable('Today metrics'), isFalse);
  });
}
