import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/screens/rider_dashboard_screen.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/screens/rider_home_screen.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_home_bottom_nav.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_keep_alive_tab.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'support/rider_dashboard_fakes.dart';
import 'support/rider_dashboard_fixture.dart';
import 'support/rider_test_models.dart';

void main() {
  testWidgets('dashboard load does not dirty a sibling during tab build', (
    tester,
  ) async {
    final gate = Completer<void>();
    final repository = FakeRiderDashboardRepository(gate: gate);
    final fixture = RiderDashboardFixture(dashboardRepository: repository);
    addTearDown(fixture.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AnimatedBuilder(
                animation: fixture.dashboard,
                builder: (context, _) => Text(
                  'Unread: ${fixture.dashboard.metrics.unreadMessageCount}',
                ),
              ),
              Expanded(
                child: PageView.builder(
                  itemCount: 1,
                  itemBuilder: (context, index) => RiderKeepAliveTab(
                    child: RiderDashboardScreen(
                      profile: verifiedRiderProfile(),
                      riderId: 'rider-a',
                      deliveryController: fixture.delivery,
                      availabilityController: fixture.availability,
                      dashboardController: fixture.dashboard,
                      onOpenDeliveries: () {},
                      onOpenMap: () {},
                      onOpenMessages: () {},
                      onOpenEarnings: () {},
                      onOpenNotifications: () {},
                      onSafetySupport: () {},
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(repository.fetchCalls, 1);
    gate.complete();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final disposeBeforeProfile in [false, true]) {
    testWidgets(
      'pending profile keeps home visible; disposed=$disposeBeforeProfile',
      (tester) async {
        final profile = Completer<RiderProfile?>();
        final fixture = RiderDashboardFixture(
          dashboardRepository: FakeRiderDashboardRepository(),
        );
        addTearDown(fixture.dispose);
        await tester.pumpWidget(
          MaterialApp(
            home: RiderHomeScreen(
              profileLoader: () => profile.future,
              deliveryController: fixture.delivery,
              availabilityController: fixture.availability,
              dashboardController: fixture.dashboard,
              locationController: fixture.location,
            ),
          ),
        );
        expect(find.byType(RiderHomeBottomNav), findsOneWidget);
        expect(find.text('Work status'), findsOneWidget);
        expect(find.byType(RiderDashboardScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (disposeBeforeProfile)
          await tester.pumpWidget(const SizedBox.shrink());
        profile.complete(verifiedRiderProfile());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (!disposeBeforeProfile)
          expect(find.text('Hello, Rider'), findsOneWidget);
      },
    );
  }
}
