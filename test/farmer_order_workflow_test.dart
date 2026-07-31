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

    expect(find.text('Accept order'), findsOneWidget);
    await tester.tap(find.text('Accept order'));
    await tester.pumpAndSettle();

    expect(find.text('Mark ready for pickup'), findsOneWidget);
    await tester.tap(find.text('Mark ready for pickup'));
    await tester.pumpAndSettle();

    expect(find.text('Waiting for an assigned rider'), findsOneWidget);
    expect(find.text('Confirm rider pickup'), findsNothing);
    expect(orderController.orders.single.status.name, 'readyForPickup');
  });
}
