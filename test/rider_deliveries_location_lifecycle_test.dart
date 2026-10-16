import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/screens/rider_home_screen.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_home_bottom_nav.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_request_state_card.dart';
import 'support/rider_dashboard_fixture.dart';
import 'support/rider_dashboard_fakes.dart';
import 'support/rider_test_models.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'Deliveries starts GPS without an active delivery and refreshes on resume',
    (tester) async {
      final fixture = RiderDashboardFixture(
        dashboardRepository: FakeRiderDashboardRepository(),
      );
      addTearDown(fixture.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: RiderHomeScreen(
            profileLoader: () async => verifiedRiderProfile(),
            deliveryController: fixture.delivery,
            availabilityController: fixture.availability,
            dashboardController: fixture.dashboard,
            locationController: fixture.location,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(fixture.location.startTrackingCalls, 0);
      final nav = tester.widget<RiderHomeBottomNav>(
        find.byType(RiderHomeBottomNav),
      );
      nav.onSelected(RiderHomeScreen.deliveriesNavIndex);
      await tester.pumpAndSettle();
      expect(fixture.location.startTrackingCalls, 1);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      final before = fixture.location.refreshCalls;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(fixture.location.refreshCalls, greaterThan(before));
      expect(fixture.location.startTrackingCalls, greaterThan(1));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('pending GPS shows progress instead of an unavailable warning', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RiderRequestAccessCard(
            state: RiderRequestAccessState.locationUnavailable,
            isCheckingLocation: true,
          ),
        ),
      ),
    );
    expect(find.text('Finding your location'), findsOneWidget);
    expect(find.text('Location unavailable'), findsNothing);
  });
}
