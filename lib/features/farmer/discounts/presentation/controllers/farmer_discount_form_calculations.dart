import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';

abstract final class FarmerDiscountFormCalculations {
  static String previewPrice({
    required FarmerDashboardProduct product,
    required String valueText,
    required String discountType,
  }) {
    final val = double.tryParse(valueText.trim()) ?? 0.0;
    if (val <= 0) return product.price;

    final base =
        double.tryParse(
          RegExp(r'[\d.]+').firstMatch(product.price)?.group(0) ?? '',
        ) ??
        0.0;

    double result;
    if (discountType == 'percentage') {
      result = base * (1 - val / 100);
    } else if (discountType == 'sale_price') {
      result = val;
    } else {
      result = base - val;
    }

    if (result <= 0) return 'Invalid discount';
    return '\u20b1${result.toStringAsFixed(2)}';
  }

  static String? validateDiscountForm({
    required String name,
    required double? value,
    required String discountType,
    required DateTime? startsAt,
    required DateTime? endsAt,
    required Set<int> selectedCommodityIds,
  }) {
    if (name.isEmpty) {
      return 'Please enter a promotion name.';
    }
    if (value == null || value <= 0) {
      return 'Please enter a valid discount value.';
    }
    if (discountType == 'percentage' && value > 90) {
      return 'Percentage discount cannot exceed 90%.';
    }
    if (endsAt != null && startsAt != null && endsAt.isBefore(startsAt)) {
      return 'End date must be after start date.';
    }
    if (selectedCommodityIds.isEmpty) {
      return 'Select at least one product for this discount.';
    }
    return null;
  }
}
