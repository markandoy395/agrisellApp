import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_order_workflow_card.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'package:agresell_app/features/shared/orders/presentation/widgets/order_acceptance_deadline_card.dart';

void main() {
  testWidgets('buyer sees a compact accessible acceptance countdown', (
    tester,
  ) async {
    final order = _order(
      expiresAt: DateTime.now().add(const Duration(hours: 2, minutes: 5)),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: OrderAcceptanceDeadlineCard(
              order: order,
              audience: OrderDeadlineAudience.buyer,
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('left'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('left')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('order-deadline-info')));
    await tester.pump();
    expect(
      find.textContaining('Waiting for the farmer to respond.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('farmer reviews payment without restoring an expired order', (
    tester,
  ) async {
    final order = _order(
      expiresAt: DateTime.now().subtract(const Duration(minutes: 2)),
      expiredAt: DateTime.now().subtract(const Duration(minutes: 1)),
      payment: const OrderPayment(
        method: OrderPaymentMethod.gcash,
        status: OrderPaymentStatus.paymentReviewRequired,
        transactionReference: '1234567890123',
      ),
    );
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: FarmerOrderWorkflowCard(
              order: order,
              controller: OrderController.instance,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Expired'), findsOneWidget);
    expect(find.text('Deadline expired'), findsOneWidget);
    expect(find.text('Payment review required'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);
    expect(find.text('Accept order'), findsNothing);

    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    expect(find.text('Review expired GCash payment'), findsOneWidget);
    expect(find.text('Received'), findsOneWidget);
    expect(find.textContaining('will not restore'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

PlacedOrder _order({
  required DateTime expiresAt,
  DateTime? expiredAt,
  OrderPayment payment = const OrderPayment.cashOnDelivery(),
}) => PlacedOrder(
  id: 'ORD-DEADLINE-F1',
  status: expiredAt == null
      ? PlacedOrderStatus.toShip
      : PlacedOrderStatus.cancelled,
  placedAt: DateTime.now().subtract(const Duration(hours: 1)),
  deliveryAddress: 'Malaybalay City, Bukidnon',
  phoneNumber: '09171234567',
  acceptanceExpiresAt: expiresAt,
  acceptanceExpiredAt: expiredAt,
  payment: payment,
  items: const [
    PlacedOrderItem(
      productId: '1',
      productName: 'Fresh tomatoes',
      image: 'assets/images/vege.jpeg',
      sellerName: 'Test Farmer',
      pricePerKg: 50,
      unit: 'kg',
      quantity: 2,
    ),
  ],
);
