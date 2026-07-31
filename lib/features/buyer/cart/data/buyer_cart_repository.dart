import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/buyer/cart/domain/basket_cart_item.dart';

class BuyerCartRepository {
  const BuyerCartRepository();

  Future<void> save(Iterable<BasketCartItem> items) async {
    if (!AgrisellSupabase.isInitialized) return;
    final cartItems = items.map(_itemPayload).toList(growable: false);
    await AgrisellSupabase.client.rpc<void>(
      'replace_current_buyer_cart',
      params: {'cart_items': cartItems},
    );
  }

  Map<String, Object> _itemPayload(BasketCartItem item) {
    final commodityId = int.tryParse(item.productId);
    if (commodityId == null) {
      throw StateError('Cart item does not have a valid commodity ID.');
    }
    return {
      'commodity_id': commodityId,
      'quantity': item.quantity,
      'price_at_time': item.pricePerKg,
    };
  }
}
