import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/dashboard/presentation/screens/rider_home_screen.dart';

import 'support/rider_dashboard_fakes.dart';
import 'support/rider_dashboard_fixture.dart';

void main() {
  testWidgets('tab switching preserves dashboard without reloading', (
    tester,
  ) async {
    final repository = FakeRiderDashboardRepository();
    final fixture = RiderDashboardFixture(dashboardRepository: repository);
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: RiderHomeScreen(
          deliveryController: fixture.delivery,
          availabilityController: fixture.availability,
          dashboardController: fixture.dashboard,
          locationController: fixture.location,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(repository.fetchCalls, 1);

    await tester.tap(find.text('Deliveries'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(repository.fetchCalls, 1);
  });

  testWidgets('resume does not request rider data without a backend profile', (
    tester,
  ) async {
    final repository = FakeRiderDashboardRepository();
    final fixture = RiderDashboardFixture(
      dashboardRepository: repository,
      staleAfter: Duration.zero,
    );
    addTearDown(fixture.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: RiderHomeScreen(
          deliveryController: fixture.delivery,
          availabilityController: fixture.availability,
          dashboardController: fixture.dashboard,
          locationController: fixture.location,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final initialCalls = repository.fetchCalls;

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(milliseconds: 1));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(repository.fetchCalls, initialCalls);
  });
}
