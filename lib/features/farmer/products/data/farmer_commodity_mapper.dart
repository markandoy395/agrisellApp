import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/shared/products/domain/product_sale_status.dart';
import 'package:agresell_app/features/shared/products/domain/product_inventory_lot.dart';

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
      inventoryDateType: productInventoryDateTypeFromDatabase(
        FarmerCommodityFormat.optionalText(row['inventory_date_type']),
      ),
      harvestedAt: DateTime.tryParse(
        FarmerCommodityFormat.text(row['next_harvested_at']),
      ),
      sellUntil: DateTime.tryParse(
        FarmerCommodityFormat.text(row['next_sell_until']),
      ),
      expiresAt: DateTime.tryParse(
        FarmerCommodityFormat.text(row['next_expires_at']),
      ),
      lotCode: FarmerCommodityFormat.optionalText(row['next_lot_code']),
      storageInstructions: FarmerCommodityFormat.optionalText(
        row['storage_instructions'],
      ),
      activeSaleName: FarmerCommodityFormat.optionalText(row['active_sale_name']),
      activeSaleDiscount: FarmerCommodityFormat.optionalText(
        row['active_sale_discount'],
      ),
      activeSaleEndsAt: DateTime.tryParse(
        FarmerCommodityFormat.text(row['active_sale_ends_at']),
      ),
      activeSaleId: FarmerCommodityFormat.integer(row['active_sale_id']),
      activeSaleIsFarmerOwned: row['active_sale_is_farmer_owned'] == true,
      activeSaleType: FarmerCommodityFormat.optionalText(row['active_sale_type']),
      activeSaleValue: (row['active_sale_value'] as num?)?.toDouble(),
      activeSalePromoCode: FarmerCommodityFormat.optionalText(
        row['active_sale_promo_code'],
      ),
      activeSaleStartsAt: DateTime.tryParse(
        FarmerCommodityFormat.text(row['active_sale_starts_at']),
      ),
    );
  }
}
