import 'support/home_product_fixture.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final controller = BasketController.instance;

  setUp(controller.clear);
  tearDown(controller.clear);

  test('addProduct stores real product data and increases quantity', () {
    final product = testHomeProducts.first;

    controller.addProduct(product);
    controller.addProduct(product);

    expect(controller.items, hasLength(1));
    expect(controller.items.single.productId, product.id);
    expect(controller.items.single.productName, product.name);
    expect(controller.items.single.image, product.image);
    expect(controller.items.single.imageUrl, product.imageUrl);
    expect(controller.items.single.sellerName, product.sellerName);
    expect(controller.items.single.quantity, 2);
    expect(controller.totalQuantity, 2);
    expect(controller.selectedQuantity, 2);
    expect(controller.selectedTotal, 30);
  });

  test('selection and select all control checkout total', () {
    controller.addProduct(testHomeProducts[0]);
    controller.addProduct(testHomeProducts[1]);

    expect(controller.allSelected, isTrue);
    expect(controller.selectedQuantity, 2);
    expect(controller.selectedTotal, 50);

    controller.setSelected(testHomeProducts[0].id, false);

    expect(controller.allSelected, isFalse);
    expect(controller.selectedQuantity, 1);
    expect(controller.selectedTotal, 35);

    controller.setAllSelected(false);

    expect(controller.selectedQuantity, 0);
    expect(controller.selectedTotal, 0);

    controller.setAllSelected(true);

    expect(controller.allSelected, isTrue);
    expect(controller.selectedQuantity, 2);
    expect(controller.selectedTotal, 50);
  });

  test('unavailable products cannot be added to the basket', () {
    final unavailableProduct = testHomeProducts.firstWhere(
      (product) => !product.isAvailable,
    );

    controller.addProduct(unavailableProduct, quantity: 3);

    expect(controller.items, isEmpty);
    expect(controller.totalQuantity, 0);
  });

  test('inventory refresh removes depleted items and caps reduced stock', () {
    controller.addProduct(testHomeProducts[0], quantity: 5);
    controller.addProduct(testHomeProducts[1], quantity: 4);

    final changed = controller.reconcileAvailableQuantities({
      testHomeProducts[0].id: 0,
      testHomeProducts[1].id: 2,
    });

    expect(changed, isTrue);
    expect(controller.items, hasLength(1));
    expect(controller.items.single.productId, testHomeProducts[1].id);
    expect(controller.items.single.quantity, 2);
    expect(controller.totalQuantity, 2);
  });

  test(
    'basket items can be removed and restored without losing their state',
    () {
      final product = testHomeProducts.first;
      controller.addProduct(product, quantity: 3);
      controller.setSelected(product.id, false);

      final removed = controller.removeProduct(product.id);

      expect(removed, isNotNull);
      expect(removed!.quantity, 3);
      expect(removed.isSelected, isFalse);
      expect(controller.items, isEmpty);

      controller.restoreItems([removed]);

      expect(controller.items, hasLength(1));
      expect(controller.items.single.quantity, 3);
      expect(controller.items.single.isSelected, isFalse);
      expect(controller.totalQuantity, 3);
      expect(controller.selectedQuantity, 0);
    },
  );
}
