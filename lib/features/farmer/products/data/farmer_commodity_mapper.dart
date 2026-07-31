import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/shared/products/domain/product_sale_status.dart';

import 'farmer_commodity_format.dart';

abstract final class FarmerCommodityMapper {
  static const _placeholderImage = 'assets/images/vege.jpeg';

  static FarmerDashboardProduct productFromRow(
    Map<String, dynamic> row,
    Map<int, String> categories,
    int farmId,
  ) {
    final categoryId = FarmerCommodityFormat.integer(row['category_id']);
    final imageUrl = FarmerCommodityFormat.optionalText(row['image_url']);
    final unitType = FarmerCommodityFormat.text(
      row['unit_type'],
      fallback: 'kg',
    );
    return FarmerDashboardProduct(
      commodityId: FarmerCommodityFormat.integer(row['commodity_id']),
      farmId: farmId,
      name: FarmerCommodityFormat.text(row['commodity_name']),
      price:
          '\u20b1${FarmerCommodityFormat.displayNumber(row['price_per_unit'])}',
      unit: 'per $unitType',
      harvestDate: FarmerCommodityFormat.displayDate(
        FarmerCommodityFormat.text(row['harvest_date']),
      ),
      category: categories[categoryId] ?? 'Uncategorized',
      availableWeight:
          '${FarmerCommodityFormat.displayNumber(row['available_quantity'])} $unitType',
      description: FarmerCommodityFormat.text(row['description']),
      unitType: unitType,
      minimumOrderQuantity: row['minimum_order_quantity'] == null
          ? ''
          : FarmerCommodityFormat.displayNumber(row['minimum_order_quantity']),
      gradeQuality: FarmerCommodityFormat.optionalText(row['grade_quality']),
      isOrganic: row['is_organic'] == true,
      productionStatus: FarmerCommodityFormat.text(
        row['production_status'],
        fallback: 'harvested',
      ),
      saleStatus: productSaleStatusFromDatabase(
        FarmerCommodityFormat.text(
          row['availability_status'],
          fallback: FarmerCommodityFormat.text(row['production_status']),
        ),
      ),
      imageUrl: imageUrl,
      imageAsset: imageUrl == null ? _placeholderImage : null,
      isSold:
          FarmerCommodityFormat.text(row['commodity_status']).toLowerCase() ==
          'sold',
    );
  }
}
