import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/home_product_fixture.dart';

void main() {
  final basket = BasketController.instance;
  final orders = OrderController.instance;

  setUp(() {
    basket.clear();
    orders.clear();
  });
  tearDown(() {
    basket.clear();
    orders.clear();
  });

  test('buyer cannot cancel an order after farmer acceptance', () async {
    basket.addProduct(testHomeProducts.first);
    final order = await orders.placeToShipOrder(
      items: basket.selectedItems,
      deliveryAddress: 'Test address',
      phoneNumber: '09123456789',
    );

    await orders.acceptOrder(order!.id);
    expect(orders.orders.single.status, PlacedOrderStatus.preparing);
    expect(orders.orders.single.status.canCancel, isFalse);

    await orders.cancelOrder(order.id);
    expect(orders.orders.single.status, PlacedOrderStatus.preparing);
  });
}
