import 'support/home_product_fixture.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/screens/farmer_reserve_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final basketController = BasketController.instance;
  final orderController = OrderController.instance;

  setUp(() {
    basketController.clear();
    orderController.clear();
  });

  tearDown(() {
    basketController.clear();
    orderController.clear();
  });

  testWidgets('farmer prepares an order and waits for an assigned rider', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    basketController.addProduct(testHomeProducts.first);
    await orderController.placeToShipOrder(
      items: basketController.selectedItems,
      deliveryAddress: 'Test address',
      phoneNumber: 'Test phone',
    );

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: FarmerReserveScreen())),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(
        ValueKey('farmer-order-card-${orderController.orders.single.id}'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Accept order').first);
    expect(find.text('Accept order'), findsWidgets);
    await tester.tap(find.text('Accept order').first);
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Mark ready for pickup').first);
    expect(find.text('Mark ready for pickup'), findsWidgets);
    await tester.tap(find.text('Mark ready for pickup').first);
    await tester.pumpAndSettle();

    expect(find.text('Waiting for an assigned rider'), findsOneWidget);
    expect(find.text('Confirm rider pickup'), findsNothing);
    expect(orderController.orders.single.status.name, 'readyForPickup');
  });
}
