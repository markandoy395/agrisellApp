abstract final class FarmerCommodityWriteValues {
  static Map<String, Object?> forUpdate(Map<String, Object?> values) {
    return Map<String, Object?>.of(values)..remove('farm_id');
  }
}
