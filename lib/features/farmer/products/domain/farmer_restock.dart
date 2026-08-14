class FarmerRestockRequest {
  const FarmerRestockRequest({required this.quantity, this.reason});

  final double quantity;
  final String? reason;
}

abstract final class FarmerRestockRules {
  static const maxStock = 1000000.0;

  static String? validate(String? value, {required double currentStock}) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Enter the quantity to add.';
    if (!RegExp(r'^\d+(?:\.\d{1,3})?$').hasMatch(input)) {
      return 'Enter a valid quantity with up to 3 decimal places.';
    }
    final quantity = double.tryParse(input);
    if (quantity == null || !quantity.isFinite) {
      return 'Enter a valid quantity.';
    }
    if (quantity <= 0) return 'Quantity must be greater than zero.';
    if (quantity > maxStock || currentStock + quantity > maxStock) {
      return 'Resulting stock cannot exceed 1,000,000.';
    }
    return null;
  }

  static double parse(String value) => double.parse(value.trim());
}
