abstract final class FarmerCommodityWriteValues {
  static Map<String, Object?> forUpdate(Map<String, Object?> values) {
    return Map<String, Object?>.of(values)
      ..remove('farm_id')
      // Existing stock is changed only through the atomic restock/checkout
      // database functions, never through the general product editor.
      ..remove('available_quantity')
      // The inventory type is owned by the same lot workflow. Including it in
      // a regular edit requires a restricted column permission and causes the
      // entire product update (including a new image URL) to be rejected.
      ..remove('inventory_date_type');
  }
}
