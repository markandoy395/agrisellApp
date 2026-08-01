import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/shared/orders/domain/basket_cart_item.dart';
import 'package:agresell_app/features/buyer/orders/presentation/screens/order_tracking_screen.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final orderController = OrderController.instance;

  setUp(orderController.clear);
  tearDown(orderController.clear);

  testWidgets('order actions stay in one row on compact screens', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await orderController.placeToShipOrder(
      items: const [
        BasketCartItem(
          productId: 'product-1',
          productName: 'Test Produce',
          image: 'assets/images/home/vegetable.png',
          sellerName: 'Test Farmer',
          sellerLocation: 'Test Farm',
          harvestDate: 'Today',
          availableWeight: '10 kg',
          priceLabel: '₱50/kg',
          pricePerKg: 50,
          unit: 'kg',
          quantity: 1,
          isSelected: true,
        ),
      ],
      deliveryAddress: 'Test address',
      phoneNumber: '09123456789',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: const OrderTrackingScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final actionCenters = [
      tester.getCenter(find.text('Details')),
      tester.getCenter(find.text('Cancel')),
      tester.getCenter(find.text('Chat')),
    ];
    expect(
      actionCenters.map((center) => center.dy).toSet(),
      hasLength(1),
      reason: 'Order actions should not wrap on compact screens.',
    );
    expect(tester.takeException(), isNull);
  });
}
