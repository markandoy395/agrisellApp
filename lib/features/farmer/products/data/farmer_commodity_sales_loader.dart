import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_format.dart';

abstract final class FarmerCommoditySalesLoader {
  static Future<Map<int, Map<String, dynamic>>> loadActiveSales(
    List<Map<String, dynamic>> commodityRows,
  ) async {
    final commodityIds = commodityRows
        .map((row) => FarmerCommodityFormat.integer(row['commodity_id']))
        .whereType<int>()
        .toList(growable: false);
    if (commodityIds.isEmpty) return const {};

    try {
      final saleItemsResponse = await AgrisellSupabase.client
          .from('product_sale_items')
          .select(
            'commodity_id, product_sales!inner(sale_id, farm_id, name, promo_code, discount_type, discount_value, starts_at, ends_at, is_enabled)',
          )
          .inFilter('commodity_id', commodityIds)
          .eq('product_sales.is_enabled', true);

      final salesMap = <int, Map<String, dynamic>>{};
      final now = DateTime.now();

      for (final raw
          in (saleItemsResponse as List).whereType<Map<String, dynamic>>()) {
        final commodityId = FarmerCommodityFormat.integer(raw['commodity_id']);
        if (commodityId <= 0) continue;

        final sale = raw['product_sales'] as Map<String, dynamic>?;
        if (sale == null) continue;

        final startsAtStr = sale['starts_at'] as String?;
        final endsAtStr = sale['ends_at'] as String?;
        if (startsAtStr != null &&
            DateTime.tryParse(startsAtStr)?.isAfter(now) == true) {
          continue;
        }
        if (endsAtStr != null &&
            DateTime.tryParse(endsAtStr)?.isBefore(now) == true) {
          continue;
        }

        final discountType = sale['discount_type'] as String? ?? 'percentage';
        final discountValue =
            (sale['discount_value'] as num?)?.toDouble() ?? 0.0;
        final discountLabel = discountType == 'percentage'
            ? '${discountValue.toStringAsFixed(discountValue.truncateToDouble() == discountValue ? 0 : 2)}% OFF'
            : '\u20b1${discountValue.toStringAsFixed(2)} OFF';

        salesMap[commodityId] = {
          'active_sale_name': sale['name'] as String? ?? 'Admin Sale',
          'active_sale_discount': discountLabel,
          'active_sale_ends_at': endsAtStr,
          'active_sale_id': sale['sale_id'],
          'active_sale_is_farmer_owned': sale['farm_id'] != null,
          'active_sale_type': discountType,
          'active_sale_value': discountValue,
          'active_sale_promo_code': sale['promo_code'],
          'active_sale_starts_at': startsAtStr,
        };
      }
      return salesMap;
    } catch (_) {
      return const {};
    }
  }
}
