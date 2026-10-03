import 'dart:math';

import 'package:agresell_app/features/shared/orders/domain/basket_cart_item.dart';

double calculateCheckoutVoucherDiscount({
  required List<BasketCartItem> items,
  required Set<int> applicableIds,
  required String discountType,
  required double discountValue,
}) {
  var discount = 0.0;
  var eligibleTotal = 0.0;

  for (final item in items) {
    final parsedId = int.tryParse(item.productId.trim());
    final isApplicable =
        applicableIds.isEmpty ||
        (parsedId != null && applicableIds.contains(parsedId));
    if (!isApplicable) continue;

    final itemTotal = item.quantity * item.pricePerKg;
    eligibleTotal += itemTotal;

    if (discountType == 'percentage') {
      discount += itemTotal * (discountValue / 100);
    } else if (discountType == 'sale_price') {
      final originalTotal = itemTotal;
      final newTotal = item.quantity * discountValue;
      if (newTotal < originalTotal) {
        discount += (originalTotal - newTotal);
      }
    }
  }

  if (discountType == 'amount') {
    discount = min(eligibleTotal, discountValue);
  }

  return double.parse(discount.toStringAsFixed(2));
}
