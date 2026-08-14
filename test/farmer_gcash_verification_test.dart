import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/shared/orders/domain/basket_cart_item.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/screens/farmer_reserve_screen.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'support/home_product_fixture.dart';

void main() {
  final controller = OrderController.instance;

  setUp(controller.clear);
  tearDown(controller.clear);

  testWidgets('farmer verifies GCash before accepting the order', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final order = await controller.placeToShipOrder(
      items: [BasketCartItem.fromProduct(testHomeProducts.first)],
      deliveryAddress: 'Test address',
      phoneNumber: '09171234567',
      payment: OrderPayment.gcash(
        '1234567890123',
        receiptImageReference: 'local-secure://gcash-receipts/test',
        receiptImageName: 'gcash-receipt.png',
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: FarmerReserveScreen())),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(ValueKey('farmer-order-card-${controller.orders.single.id}')),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Verification pending').first);
    expect(find.text('Verification pending'), findsWidgets);
    expect(find.text('Review'), findsOneWidget);
    expect(find.text('Accept order'), findsNothing);

    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    expect(find.text('Review GCash reference'), findsOneWidget);
    expect(find.text('1234567890123'), findsOneWidget);
    expect(find.text('Receipt image uploaded'), findsOneWidget);
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();

    expect(
      controller.orders.single.payment.status,
      OrderPaymentStatus.verified,
    );
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Accept order').first);
    expect(find.text('Accept order'), findsOneWidget);
    await tester.tap(find.text('Accept order'));
    await tester.pumpAndSettle();
    expect(controller.orders.single.id, order!.id);
    expect(find.text('Preparing'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('farmer records a required GCash refund', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final order = await controller.placeToShipOrder(
      items: [BasketCartItem.fromProduct(testHomeProducts.first)],
      deliveryAddress: 'Test address',
      phoneNumber: '09171234567',
      payment: const OrderPayment(
        method: OrderPaymentMethod.gcash,
        status: OrderPaymentStatus.verified,
        transactionReference: '1234567890123',
      ),
    );
    await controller.cancelOrder(order!.id);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: FarmerReserveScreen())),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(ValueKey('farmer-order-card-${controller.orders.single.id}')),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Refund required').first);
    expect(find.text('Refund required'), findsWidgets);
    expect(find.text('Refund'), findsOneWidget);

    await tester.tap(find.text('Refund'));
    await tester.pumpAndSettle();
    expect(find.text('Record GCash refund'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('gcash-refund-reference')),
      'REFUND-123456',
    );
    await tester.tap(find.text('Confirm refund completed'));
    await tester.pumpAndSettle();

    expect(
      controller.orders.single.payment.status,
      OrderPaymentStatus.refunded,
    );
    expect(tester.takeException(), isNull);
  });
}
