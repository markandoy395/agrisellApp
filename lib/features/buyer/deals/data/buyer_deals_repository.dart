import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/buyer/deals/domain/deal_voucher.dart';

class BuyerDealsRepository {
  const BuyerDealsRepository({
    this.customDealsLoader,
  });

  final Future<List<DealVoucher>> Function()? customDealsLoader;

  bool get isAvailable => AgrisellSupabase.isInitialized;

  Future<List<DealVoucher>> loadActiveDeals() async {
    if (customDealsLoader != null) {
      return customDealsLoader!();
    }

    if (!isAvailable) return const [];

    final client = AgrisellSupabase.client;
    try {
      final rows = await client.rpc<List<dynamic>>('marketplace_active_deals');
      return rows
          .whereType<Map<String, dynamic>>()
          .map(DealVoucher.fromRow)
          .toList(growable: false);
    } catch (_) {
      try {
        final rows = await client
            .from('product_sales')
            .select('sale_id, name, promo_code, discount_type, discount_value, target_user_group, starts_at, ends_at, is_enabled, promote_on_home')
            .eq('is_enabled', true)
            .order('starts_at', ascending: true);

        final now = DateTime.now();
        return (rows as List)
            .whereType<Map<String, dynamic>>()
            .map(DealVoucher.fromRow)
            .where((deal) => !deal.isExpiredAt(now))
            .toList(growable: false);
      } catch (_) {
        return const [];
      }
    }
  }

  Future<Set<int>> loadApplicableCommodityIds(int saleId) async {
    if (!isAvailable) return const {};

    try {
      final rows = await AgrisellSupabase.client
          .from('product_sale_items')
          .select('commodity_id')
          .eq('sale_id', saleId);

      return (rows as List)
          .whereType<Map<String, dynamic>>()
          .map((row) => row['commodity_id'])
          .whereType<int>()
          .toSet();
    } catch (_) {
      return const {};
    }
  }
}
