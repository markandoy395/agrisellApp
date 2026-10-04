import 'support/authenticated_test_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/buyer/orders/presentation/screens/buyer_refund_tracker_screen.dart';
import 'package:agresell_app/features/buyer/orders/presentation/widgets/buyer_refund_detail_sheet.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/orders_card.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';

void main() {
  configureAuthenticatedTests();
  final orderController = OrderController.instance;

  setUp(orderController.clear);
  tearDown(orderController.clear);

  PlacedOrder createTestOrder({
    required String id,
    required OrderPayment payment,
    PlacedOrderStatus status = PlacedOrderStatus.cancelled,
  }) {
    return PlacedOrder(
      id: id,
      status: status,
      placedAt: DateTime(2026, 9, 15, 10, 30),
      deliveryAddress: '123 Farm Road, Benguet',
      phoneNumber: '09171234567',
      items: const [
        PlacedOrderItem(
          productId: '1',
          productName: 'Fresh Strawberries',
          image: 'assets/strawberry.png',
          sellerName: 'Highland Farm',
          pricePerKg: 150.0,
          unit: 'kg',
          quantity: 2,
        ),
      ],
      cancellationReason: 'Admin cancelled order due to item stock out',
      cancelledAt: DateTime(2026, 9, 15, 11, 00),
      payment: payment,
    );
  }

  testWidgets(
    'BuyerRefundTrackerScreen renders empty state when no refunds exist',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: const BuyerRefundTrackerScreen(),
        ),
      );

      expect(find.text('Refund Tracker'), findsOneWidget);
      expect(find.text('No refund records found'), findsOneWidget);
    },
  );

  testWidgets(
    'BuyerRefundTrackerScreen lists refunds and filters between tabs',
    (tester) async {
      final completedOrder = createTestOrder(
        id: 'ORD-REF-COMPLETED',
        payment: const OrderPayment(
          method: OrderPaymentMethod.gcash,
          status: OrderPaymentStatus.refunded,
          transactionReference: '1001234567890',
          refundReference: 'REF-COMPLETED-999',
          refundAmount: 300.0,
          refundReason: 'Stock unavailable',
          refundStatus: 'completed',
        ),
      );

      final pendingOrder = createTestOrder(
        id: 'ORD-REF-PENDING',
        payment: const OrderPayment(
          method: OrderPaymentMethod.gcash,
          status: OrderPaymentStatus.refundRequired,
          transactionReference: '1001234567891',
          refundReference: '',
          refundAmount: 300.0,
          refundReason: 'Admin review requested',
          refundStatus: 'approved',
        ),
      );

      // Place orders in controller
      orderController.setOrdersForTesting([completedOrder, pendingOrder]);

      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: const BuyerRefundTrackerScreen(),
        ),
      );

      // Default 'All Refunds' tab
      expect(find.text('ORD-REF-COMPLETED'), findsOneWidget);
      expect(find.text('ORD-REF-PENDING'), findsOneWidget);
      expect(find.text('Refund Completed'), findsOneWidget);
      expect(find.text('Refund Approved'), findsOneWidget);

      // Switch to 'Completed' tab
      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();

      expect(find.text('ORD-REF-COMPLETED'), findsOneWidget);
      expect(find.text('ORD-REF-PENDING'), findsNothing);

      // Switch to 'In Progress' tab
      await tester.tap(find.text('In Progress'));
      await tester.pumpAndSettle();

      expect(find.text('ORD-REF-PENDING'), findsOneWidget);
      expect(find.text('ORD-REF-COMPLETED'), findsNothing);
    },
  );

  testWidgets(
    'showBuyerRefundDetailSheet displays timeline and refund details',
    (tester) async {
      final order = createTestOrder(
        id: 'ORD-SHEET-TEST',
        payment: OrderPayment(
          method: OrderPaymentMethod.gcash,
          status: OrderPaymentStatus.refunded,
          transactionReference: '1001234567890',
          refundReference: 'REFUND-GCASH-123456',
          refundAmount: 300.0,
          refundedAt: DateTime(2026, 9, 15, 12, 30),
          refundReason: 'Product unavailable',
          refundStatus: 'completed',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () =>
                    showBuyerRefundDetailSheet(context, order: order),
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Refund Details & Tracker'), findsOneWidget);
      expect(find.text('Order ID: ORD-SHEET-TEST'), findsOneWidget);
      expect(find.text('Refund Progress Timeline'), findsOneWidget);
      expect(find.text('Order Cancelled'), findsOneWidget);
      expect(find.text('Refund Reviewed & Approved'), findsOneWidget);
      expect(find.text('Refund Disbursed / Completed'), findsOneWidget);
      expect(find.text('Reference: REFUND-GCASH-123456'), findsOneWidget);
      expect(find.text('Product unavailable'), findsWidgets);
    },
  );

  testWidgets(
    'OrdersCard renders Refunds shortcut and opens BuyerRefundTrackerScreen',
    (tester) async {
      final refundOrder = createTestOrder(
        id: 'ORD-REFUND-CARD',
        payment: const OrderPayment(
          method: OrderPaymentMethod.gcash,
          status: OrderPaymentStatus.refunded,
          refundReference: 'REF-123',
        ),
      );

      orderController.setOrdersForTesting([refundOrder]);

      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: const Scaffold(body: OrdersCard()),
        ),
      );

      expect(
        find.byKey(const ValueKey('buyer-refunds-shortcut')),
        findsOneWidget,
      );
      expect(find.text('Refunds & Returns · Track status'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('buyer-refunds-shortcut')));
      await tester.pumpAndSettle();

      expect(find.byType(BuyerRefundTrackerScreen), findsOneWidget);
    },
  );
}
