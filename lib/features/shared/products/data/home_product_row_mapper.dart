import 'package:agresell_app/features/shared/products/data/home_product_format.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/domain/product_inventory_lot.dart';
import 'package:agresell_app/features/shared/products/domain/product_production_stage.dart';
import 'package:agresell_app/features/shared/products/domain/product_sale_status.dart';

abstract final class HomeProductRowMapper {
  static const placeholderImage = 'assets/images/vege.jpeg';

  static HomeProduct fromRow(
    Map<String, dynamic> row, {
    Map<String, dynamic>? farm,
  }) {
    final category = HomeProductFormat.mapValue(row['categories']);
    final seller = farm ?? const <String, dynamic>{};
    final commodityStatus = HomeProductFormat.text(
      row['commodity_status'],
    ).toLowerCase();
    final saleStatus = productSaleStatusFromDatabase(
      HomeProductFormat.text(
        row['availability_status'],
        fallback: HomeProductFormat.text(row['production_status']),
      ),
    );
    final productionStage = productProductionStageFromDatabase(
      row['production_status'],
    );
    final harvestDate = HomeProductFormat.text(row['harvest_date']);

    return HomeProduct(
      id: row['commodity_id'].toString(),
      name: HomeProductFormat.text(
        row['commodity_name'],
        fallback: 'Unnamed commodity',
      ),
      price: '₱${HomeProductFormat.displayNumber(row['price_per_unit'])}',
      salePrice: salePrice(row),
      unit: 'per ${HomeProductFormat.text(row['unit_type'], fallback: 'kg')}',
      image: placeholderImage,
      imageUrl: HomeProductFormat.optionalText(row['image_url']),
      harvestDate: HomeProductFormat.displayDate(harvestDate),
      availableWeight:
          '${HomeProductFormat.displayNumber(row['available_quantity'])} '
          '${HomeProductFormat.text(row['unit_type'], fallback: 'kg')}',
      sellerName: HomeProductFormat.text(
        seller['farmer_name'],
        fallback: 'Farmer',
      ),
      sellerLocation: HomeProductFormat.text(
        seller['farm_location'],
        fallback: 'Location unavailable',
      ),
      description: HomeProductFormat.text(row['description']),
      farmId: HomeProductFormat.integer(row['farm_id']),
      rating: HomeProductFormat.number(row['rating']),
      category: HomeProductFormat.text(
        category['category_name'] ?? row['category_name'],
        fallback: 'Uncategorized',
      ),
      isAvailable:
          commodityStatus == 'available' &&
          HomeProductFormat.number(row['available_quantity']) > 0,
      isSold: commodityStatus == 'sold',
      saleStatus: saleStatus,
      productionStage: productionStage,
      estimatedHarvestDate: DateTime.tryParse(harvestDate),
      inventoryDateType: productInventoryDateTypeFromDatabase(
        HomeProductFormat.optionalText(row['inventory_date_type']),
      ),
      sellUntil: DateTime.tryParse(
        HomeProductFormat.text(row['next_sell_until']),
      ),
      expiresAt: DateTime.tryParse(
        HomeProductFormat.text(row['next_expires_at']),
      ),
      storageInstructions: HomeProductFormat.optionalText(
        row['storage_instructions'],
      ),
    );
  }

  static String? salePrice(Map<String, dynamic> row) {
    final original = HomeProductFormat.number(row['price_per_unit']);
    final effective = HomeProductFormat.number(row['effective_price']);
    if (effective <= 0 || effective >= original) return null;
    return '₱${HomeProductFormat.displayNumber(row['effective_price'])}';
  }
}
