import 'package:agresell_app/features/buyer/cart/data/checkout_voucher_service.dart';
import 'package:agresell_app/features/shared/orders/domain/basket_cart_item.dart';

abstract final class CheckoutPriceCalculator {
  static double parsePrice(String price) {
    final normalized = price.replaceAll(',', '');
    final match = RegExp(r'\d+(?:\.\d+)?').firstMatch(normalized);
    if (match == null) return 0.0;
    return double.tryParse(match.group(0) ?? '') ?? 0.0;
  }

  static double calculateItemsSubtotal(Iterable<BasketCartItem> items) {
    var subtotal = 0.0;
    for (final item in items) {
      if (item.hasSale && item.originalPriceLabel != null) {
        subtotal += item.quantity * parsePrice(item.originalPriceLabel!);
      } else {
        subtotal += item.quantity * item.pricePerKg;
      }
    }
    return double.parse(subtotal.toStringAsFixed(2));
  }

  static double calculateProductSaleDiscount(Iterable<BasketCartItem> items) {
    var discount = 0.0;
    for (final item in items) {
      if (item.hasSale && item.originalPriceLabel != null) {
        final original = parsePrice(item.originalPriceLabel!);
        if (original > item.pricePerKg) {
          discount += item.quantity * (original - item.pricePerKg);
        }
      }
    }
    return double.parse(discount.toStringAsFixed(2));
  }

  static double calculateFinalTotal({
    required double selectedTotal,
    double voucherDiscount = 0.0,
  }) {
    final total = selectedTotal - voucherDiscount;
    return total < 0 ? 0.0 : double.parse(total.toStringAsFixed(2));
  }

  static List<BasketCartItem> applyVoucherDiscounts({
    required List<BasketCartItem> items,
    required double selectedTotal,
    AppliedVoucher? appliedVoucher,
  }) {
    if (appliedVoucher == null) return items;

    return items.map((item) {
      final parsedId = int.tryParse(item.productId.trim());
      final isEligible = appliedVoucher.applicableCommodityIds.isEmpty ||
          (parsedId != null &&
              appliedVoucher.applicableCommodityIds.contains(parsedId));
      if (!isEligible) return item;

      var discountedPrice = item.pricePerKg;
      if (appliedVoucher.discountType == 'percentage') {
        discountedPrice =
            item.pricePerKg * (1 - appliedVoucher.discountValue / 100);
      } else if (appliedVoucher.discountType == 'sale_price') {
        discountedPrice = appliedVoucher.discountValue;
      } else if (appliedVoucher.discountType == 'amount') {
        final itemTotal = item.pricePerKg * item.quantity;
        final portion = itemTotal > 0 && selectedTotal > 0
            ? (appliedVoucher.discountAmount / selectedTotal)
            : 0;
        discountedPrice = (item.pricePerKg * (1 - portion)).clamp(
          0,
          double.infinity,
        );
      }
      discountedPrice = double.parse(discountedPrice.toStringAsFixed(2));
      return item.copyWith(pricePerKg: discountedPrice);
    }).toList();
  }
}
