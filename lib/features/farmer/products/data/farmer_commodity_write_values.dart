import 'package:agresell_app/features/farmer/products/data/farmer_commodity_format.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/shared/products/domain/product_sale_status.dart';

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

  static Map<String, Object?> commodityValues(
    FarmerDashboardProduct product,
    int farmId,
    int categoryId,
    String? imageUrl,
  ) => {
    'category_id': categoryId,
    'farm_id': farmId,
    'commodity_name': product.name,
    'description': product.description.isEmpty ? null : product.description,
    'price_per_unit': FarmerCommodityFormat.number(product.price),
    'unit_type': product.unitType,
    'available_quantity': FarmerCommodityFormat.number(product.availableWeight),
    'harvest_date': FarmerCommodityFormat.databaseDate(product.harvestDate),
    'production_status': product.productionStatus,
    'availability_status': product.saleStatus.databaseValue,
    'is_organic': product.isOrganic,
    'image_url': imageUrl,
    'commodity_status': product.isSold ? 'sold' : 'available',
    'minimum_order_quantity': product.minimumOrderQuantity.isEmpty
        ? null
        : FarmerCommodityFormat.number(product.minimumOrderQuantity),
    'grade_quality': product.gradeQuality,
    'inventory_date_type': product.inventoryDateType.databaseValue,
  };
}
