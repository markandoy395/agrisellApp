import 'package:agresell_app/features/buyer/cart/data/checkout_inventory_repository.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/shared/orders/domain/basket_cart_item.dart';

abstract final class CheckoutInventoryReconciler {
  static bool isInventoryFailure(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('stock') ||
        normalized.contains('remains') ||
        normalized.contains('no longer available') ||
        normalized.contains('not accepting orders');
  }

  static Future<void> refreshIfNeeded({
    required CheckoutInventoryRepository repository,
    required BasketController controller,
    required String errorMessage,
    required Iterable<BasketCartItem> submittedItems,
  }) async {
    if (!isInventoryFailure(errorMessage)) return;
    final quantities = await repository.loadOrderableQuantities(
      submittedItems.map((item) => item.productId),
    );
    controller.reconcileAvailableQuantities(quantities);
  }
}
