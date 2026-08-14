abstract final class FarmerCommodityWriteValues {
  static Map<String, Object?> forUpdate(Map<String, Object?> values) {
    return Map<String, Object?>.of(values)
      ..remove('farm_id')
      // Existing stock is changed only through the atomic restock/checkout
      // database functions, never through the general product editor.
      ..remove('available_quantity');
  }
}
