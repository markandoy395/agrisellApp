import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';

abstract interface class CheckoutInventoryRepository {
  Future<Map<String, int>> loadOrderableQuantities(Iterable<String> productIds);
}

class SupabaseCheckoutInventoryRepository
    implements CheckoutInventoryRepository {
  const SupabaseCheckoutInventoryRepository();

  @override
  Future<Map<String, int>> loadOrderableQuantities(
    Iterable<String> productIds,
  ) async {
    final ids = productIds
        .map(int.tryParse)
        .whereType<int>()
        .where((id) => id > 0)
        .toSet();
    if (ids.isEmpty || !AgrisellSupabase.isInitialized) return const {};

    try {
      final rows = await AgrisellSupabase.client
          .from('commodities')
          .select(
            'commodity_id, available_quantity, commodity_status, availability_status',
          )
          .inFilter('commodity_id', ids.toList(growable: false));
      final available = <String, int>{for (final id in ids) '$id': 0};
      for (final row in (rows as List).whereType<Map<String, dynamic>>()) {
        final id = int.tryParse(row['commodity_id'].toString());
        if (id == null) continue;
        final quantity = double.tryParse(
          row['available_quantity']?.toString() ?? '',
        );
        final isOrderable =
            row['commodity_status']?.toString().toLowerCase() == 'available' &&
            row['availability_status']?.toString().toLowerCase() !=
                'not_accepting_orders' &&
            quantity != null &&
            quantity > 0;
        available['$id'] = isOrderable ? quantity.floor() : 0;
      }
      return available;
    } on PostgrestException {
      return const {};
    }
  }
}
