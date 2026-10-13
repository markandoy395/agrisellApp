import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/screens/rider_delivery_details_screen.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_action_panel.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_quick_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final width in [320.0, 430.0]) {
    testWidgets('delivery actions stay visible at $width with enlarged text', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      await tester.binding.setSurfaceSize(Size(width, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final request = DeliveryRequest(
        id: 'delivery-75',
        orderNumber: 'Order #75',
        productName: 'Lettuce',
        sellerName: 'Farmer',
        buyerName: 'Buyer',
        pickupLocation: const DeliveryLocation(address: 'Farm'),
        deliveryLocation: const DeliveryLocation(address: 'Poblacion'),
        pickupDeadline: DateTime(2030),
        stage: DeliveryStage.accepted,
        assignedRiderId: 'rider-a',
      );
      final controller = RiderDeliveryController(
        repository: InMemoryRiderDeliveryRepository(requests: [request]),
      );
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(width, 640),
              padding: const EdgeInsets.only(bottom: 24),
              textScaler: const TextScaler.linear(1.5),
            ),
            child: RiderDeliveryDetailsScreen(
              request: request,
              controller: controller,
              riderId: 'rider-a',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Order #75'), findsWidgets);
      expect(find.text('Order Order #75'), findsNothing);
      final actions = find.byType(RiderDeliveryActionPanel);
      expect(actions, findsOneWidget);
      expect(tester.getBottomRight(actions).dy, lessThanOrEqualTo(616));
      expect(find.text('Mark Going to Pickup').hitTestable(), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.text('Mark Going to Pickup').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('all quick action labels fit and callbacks still work', (
    tester,
  ) async {
    final called = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 640),
              textScaler: TextScaler.linear(1.5),
            ),
            child: SizedBox(
              width: 280,
              child: RiderDeliveryQuickActions(
                onRoute: () => called.add('Route'),
                onMessage: () => called.add('Message'),
                onProblem: () => called.add('Problem'),
                onSafety: () => called.add('Safety'),
                onWaybill: () => called.add('Waybill'),
              ),
            ),
          ),
        ),
      ),
    );
    for (final label in ['Route', 'Message', 'Problem', 'Safety', 'Waybill']) {
      await tester.tap(find.text(label));
    }
    expect(called, ['Route', 'Message', 'Problem', 'Safety', 'Waybill']);
    expect(
      tester.getTopLeft(find.text('Safety')).dy,
      greaterThan(tester.getTopLeft(find.text('Route')).dy),
    );
    expect(tester.takeException(), isNull);
  });
}
