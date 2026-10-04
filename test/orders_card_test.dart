import 'support/authenticated_test_session.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/shared/orders/data/home_order_statuses.dart';
import 'package:agresell_app/features/shared/orders/domain/order_status.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'package:agresell_app/features/buyer/orders/presentation/screens/order_tracking_screen.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/orders_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  configureAuthenticatedTests();
  final orderController = OrderController.instance;

  setUp(orderController.clear);
  tearDown(orderController.clear);

  testWidgets('My Orders card stays overflow-free on compact screens', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: const Scaffold(
          body: Padding(padding: EdgeInsets.all(12), child: OrdersCard()),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('each My Orders shortcut opens its matching order filter', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: const Scaffold(
          body: Padding(padding: EdgeInsets.all(12), child: OrdersCard()),
        ),
      ),
    );
    expect(
      tester.takeException(),
      isNull,
      reason: 'My Orders shortcuts must fit compact screens',
    );

    for (final shortcut in homeOrderStatuses) {
      await tester.tap(find.byKey(ValueKey('my-order-${shortcut.label}')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final screen = tester.widget<OrderTrackingScreen>(
        find.byType(OrderTrackingScreen),
      );
      expect(screen.initialFilter, shortcut.filter);
      expect(
        tester.takeException(),
        isNull,
        reason: '${shortcut.label} order filter must fit compact screens',
      );

      await tester.tap(find.bySemanticsLabel('Go back'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }
  });

  test('rating moves a delivered order into the Completed filter', () {
    final deliveredOrder = PlacedOrder(
      id: 'ORD-TEST',
      status: PlacedOrderStatus.delivered,
      placedAt: DateTime(2026),
      deliveryAddress: 'Test address',
      phoneNumber: 'Test phone',
      items: const [],
    );

    expect(OrderTrackingFilter.toRate.matches(deliveredOrder), isTrue);
    expect(OrderTrackingFilter.completed.matches(deliveredOrder), isFalse);
    expect(deliveredOrder.canLeaveFeedback, isTrue);

    final ratedOrder = deliveredOrder.copyWith(isRated: true);

    expect(OrderTrackingFilter.toRate.matches(ratedOrder), isFalse);
    expect(OrderTrackingFilter.completed.matches(ratedOrder), isTrue);
    expect(ratedOrder.canLeaveFeedback, isFalse);
  });
}
