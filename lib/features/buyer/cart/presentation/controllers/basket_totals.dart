import 'package:agresell_app/features/shared/orders/domain/basket_cart_item.dart';

class BasketTotals {
  const BasketTotals({
    required this.selectedItems,
    required this.totalQuantity,
    required this.selectedQuantity,
    required this.selectedTotal,
    required this.allSelected,
  });

  static const empty = BasketTotals(
    selectedItems: <BasketCartItem>[],
    totalQuantity: 0,
    selectedQuantity: 0,
    selectedTotal: 0.0,
    allSelected: false,
  );

  final List<BasketCartItem> selectedItems;
  final int totalQuantity;
  final int selectedQuantity;
  final double selectedTotal;
  final bool allSelected;

  factory BasketTotals.compute(List<BasketCartItem> items) {
    if (items.isEmpty) return empty;

    final selected = <BasketCartItem>[];
    var totalQuantity = 0;
    var selectedQuantity = 0;
    var selectedTotal = 0.0;
    var allSelected = true;

    for (final item in items) {
      totalQuantity += item.quantity;
      if (item.isSelected) {
        selected.add(item);
        selectedQuantity += item.quantity;
        selectedTotal += item.quantity * item.pricePerKg;
      } else {
        allSelected = false;
      }
    }

    return BasketTotals(
      selectedItems: List<BasketCartItem>.unmodifiable(selected),
      totalQuantity: totalQuantity,
      selectedQuantity: selectedQuantity,
      selectedTotal: selectedTotal,
      allSelected: allSelected,
    );
  }
}

abstract final class BasketItemOperations {
  static bool reconcileQuantities(
    List<BasketCartItem> items,
    Map<String, int> quantities,
  ) {
    if (quantities.isEmpty) return false;
    var changed = false;
    for (var index = items.length - 1; index >= 0; index--) {
      final item = items[index];
      final available = quantities[item.productId];
      if (available == null) continue;
      if (available <= 0) {
        items.removeAt(index);
        changed = true;
      } else if (item.quantity > available) {
        items[index] = item.copyWith(quantity: available);
        changed = true;
      }
    }
    return changed;
  }
}
