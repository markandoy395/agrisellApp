import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_dashboard_state.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_data_source.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/screens/rider_dashboard_screen.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_location_controller.dart';

import 'support/rider_dashboard_fakes.dart';
import 'support/rider_dashboard_fixture.dart';
import 'support/rider_test_models.dart';

part 'rider_dashboard_summary_cases.dart';

void main() {
  testWidgets('dashboard shows initial loading then empty sections', (
    tester,
  ) async {
    final gate = Completer<void>();
    final repository = FakeRiderDashboardRepository(gate: gate);
    final fixture = RiderDashboardFixture(dashboardRepository: repository);
    addTearDown(fixture.dispose);

    await _pumpDashboard(tester, fixture);
    expect(find.text('Loading Rider dashboard'), findsOneWidget);

    gate.complete();
    await tester.pumpAndSettle();
    expect(find.textContaining('No active delivery'), findsOneWidget);
    expect(find.text('No nearby requests'), findsOneWidget);
  });

  testWidgets('dashboard shows server error and retry state', (tester) async {
    final repository = FakeRiderDashboardRepository(shouldFail: true);
    final fixture = RiderDashboardFixture(dashboardRepository: repository);
    addTearDown(fixture.dispose);

    await _pumpDashboard(tester, fixture);
    await tester.pumpAndSettle();

    expect(find.text('Dashboard unavailable'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.textContaining('server failure'), findsNothing);
  });

  testWidgets('active delivery summary shows status, next action, and routes', (
    tester,
  ) async {
    final request = DeliveryRequest(
      id: 'active-1',
      orderNumber: 'ORD-10',
      productName: 'Fresh carrots',
      sellerName: 'Farmer',
      buyerName: 'Buyer',
      pickupLocation: const DeliveryLocation(
        address: 'Farm pickup',
        latitude: 8.48,
        longitude: 124.65,
      ),
      deliveryLocation: const DeliveryLocation(
        address: 'Buyer destination',
        latitude: 8.49,
        longitude: 124.66,
      ),
      pickupDeadline: DateTime(2030, 1, 1, 10),
      stage: DeliveryStage.accepted,
      assignedRiderId: 'rider-a',
    );
    final fixture = RiderDashboardFixture(
      dashboardRepository: FakeRiderDashboardRepository(),
      requests: [request],
    );
    addTearDown(fixture.dispose);
    fixture.delivery.setOnline(true);
    await fixture.delivery.applyAuthoritativeAvailability(
      RiderAvailability.deliveryReserved,
      loadRequests: false,
    );
    await fixture.delivery.load(riderId: 'rider-a');

    await _pumpDashboard(tester, fixture);
    await tester.pumpAndSettle();

    expect(find.text('Fresh carrots'), findsOneWidget);
    expect(find.text('Delivery Accepted'), findsOneWidget);
    expect(find.text('Next: Start the route to pickup'), findsOneWidget);
    expect(find.text('Continue delivery'), findsOneWidget);
    expect(find.text('Map'), findsOneWidget);
  });

  testWidgets('dashboard shows all active deliveries and the real count', (
    tester,
  ) async {
    DeliveryRequest active(String id, String product) => DeliveryRequest(
      id: id,
      orderNumber: 'ORD-$id',
      productName: product,
      sellerName: 'Farmer',
      buyerName: 'Buyer',
      pickupLocation: DeliveryLocation(
        address: 'Pickup $id',
        latitude: 8.48,
        longitude: 124.65,
      ),
      deliveryLocation: DeliveryLocation(
        address: 'Delivery $id',
        latitude: 8.49,
        longitude: 124.66,
      ),
      pickupDeadline: DateTime(2030, 1, 1, 10),
      deliveryDeadline: DateTime(2030, 1, 1, 12),
      totalWeightKg: 10,
      stage: DeliveryStage.accepted,
      assignedRiderId: 'rider-a',
    );

    final fixture = RiderDashboardFixture(
      dashboardRepository: FakeRiderDashboardRepository(),
      requests: [active('1', 'Tomatoes'), active('2', 'Carrots')],
    );
    addTearDown(fixture.dispose);
    await fixture.delivery.applyAuthoritativeAvailability(
      RiderAvailability.deliveryReserved,
      loadRequests: false,
    );
    await fixture.delivery.load(riderId: 'rider-a');

    await _pumpDashboard(tester, fixture);
    await tester.pumpAndSettle();

    expect(find.text('2 active deliveries'), findsOneWidget);
    expect(find.textContaining('Tomatoes'), findsOneWidget);
    expect(find.textContaining('Carrots'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Active now'), findsOneWidget);
    expect(find.text('2'), findsWidgets);
  });

  testWidgets('dashboard distinguishes no internet and GPS disabled', (
    tester,
  ) async {
    final fixture = RiderDashboardFixture(
      dashboardRepository: FakeRiderDashboardRepository(),
    );
    addTearDown(fixture.dispose);
    fixture.connectivity.emit(false);
    await fixture.availability.initialize(riderId: 'rider-a');

    await _pumpDashboard(tester, fixture);
    await tester.pumpAndSettle();
    expect(find.text('No internet connection'), findsOneWidget);

    fixture.connectivity.emitStatus(RiderInternetStatus.backendUnavailable);
    await fixture.availability.refreshEnvironment();
    await tester.pumpAndSettle();
    expect(find.text('AgriSell is unavailable'), findsOneWidget);

    fixture.connectivity.emit(true);
    fixture.location.fakeState = RiderLocationState.serviceDisabled;
    await fixture.availability.refreshEnvironment(refreshLocation: true);
    await tester.pumpAndSettle();
    expect(find.text('GPS is disabled'), findsOneWidget);
    expect(find.text('Enable GPS'), findsOneWidget);
  });

  testWidgets('availability toggle keeps dashboard layout free of loading UI', (
    tester,
  ) async {
    final fixture = RiderDashboardFixture(
      dashboardRepository: FakeRiderDashboardRepository(),
    );
    addTearDown(fixture.dispose);
    await fixture.availability.initialize(riderId: 'rider-a');
    final saveGate = Completer<void>();
    fixture.availabilityRepository.saveGate = saveGate;

    await _pumpDashboard(tester, fixture);
    await tester.pumpAndSettle();
    expect(find.text('Work status'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(fixture.availability.isBusy, isTrue);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Work status'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Today at a glance'), findsOneWidget);

    saveGate.complete();
    await tester.pumpAndSettle();
  });

  registerRiderDashboardSummaryCases();
}

Future<void> _pumpDashboard(
  WidgetTester tester,
  RiderDashboardFixture fixture, {
  VoidCallback? onOpenEarnings,
  VoidCallback? onOpenMessages,
  VoidCallback? onOpenNotifications,
  VoidCallback? onSafetySupport,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: RiderDashboardScreen(
          profile: verifiedRiderProfile(),
          deliveryController: fixture.delivery,
          availabilityController: fixture.availability,
          dashboardController: fixture.dashboard,
          riderId: 'rider-a',
          onOpenDeliveries: () {},
          onOpenMap: () {},
          onOpenMessages: onOpenMessages ?? () {},
          onOpenEarnings: onOpenEarnings ?? () {},
          onOpenNotifications: onOpenNotifications ?? () {},
          onSafetySupport: onSafetySupport ?? () {},
        ),
      ),
    ),
  );
}
