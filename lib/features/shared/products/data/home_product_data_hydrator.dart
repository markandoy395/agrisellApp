import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/shared/products/data/home_product_format.dart';

abstract final class HomeProductDataHydrator {
  static Future<(List<Map<String, dynamic>>, Map<int, Map<String, dynamic>>)>
  hydrate(List<Map<String, dynamic>> rows) async {
    final results = await Future.wait<Object>([
      withInventorySummaries(rows),
      loadFarms(rows),
    ]);
    return (
      results[0] as List<Map<String, dynamic>>,
      results[1] as Map<int, Map<String, dynamic>>,
    );
  }

  static Future<Map<int, Map<String, dynamic>>> loadFarms(
    List<Map<String, dynamic>> commodities,
  ) async {
    final farmIds = commodities
        .map((row) => HomeProductFormat.integer(row['farm_id']))
        .whereType<int>()
        .toSet()
        .toList(growable: false);
    if (farmIds.isEmpty) return const {};

    try {
      final rows = await AgrisellSupabase.client.rpc(
        'marketplace_farm_details',
        params: {'farm_ids': farmIds},
      );
      return {
        for (final row in (rows as List).whereType<Map<String, dynamic>>())
          if (HomeProductFormat.integer(row['farm_id']) case final int farmId)
            farmId: row,
      };
    } on PostgrestException {
      return const {};
    }
  }

  static Future<List<Map<String, dynamic>>> withInventorySummaries(
    List<Map<String, dynamic>> commodities,
  ) async {
    if (commodities.isEmpty) return commodities;
    final ids = commodities
        .map((row) => HomeProductFormat.integer(row['commodity_id']))
        .whereType<int>()
        .toList(growable: false);
    final response = await AgrisellSupabase.client.rpc<List<dynamic>>(
      'marketplace_inventory_lot_summaries',
      params: {'p_commodity_ids': ids},
    );
    final summaries = <int, Map<String, dynamic>>{
      for (final row in response.whereType<Map<String, dynamic>>())
        if (HomeProductFormat.integer(row['commodity_id']) case final int id)
          id: row,
    };
    return [
      for (final commodity in commodities)
        <String, dynamic>{
          ...commodity,
          if (summaries[HomeProductFormat.integer(commodity['commodity_id'])]
              case final summary?)
            ...summary,
        },
    ];
  }
}
