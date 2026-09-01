import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/shared/products/data/home_product_format.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/domain/product_sale_status.dart';
import 'package:agresell_app/features/shared/products/domain/product_production_stage.dart';
import 'package:agresell_app/features/shared/products/domain/product_inventory_lot.dart';

class HomeProductRepository {
  const HomeProductRepository();

  static const _placeholderImage = 'assets/images/vege.jpeg';
  bool get isAvailable => AgrisellSupabase.isInitialized;

  Future<List<HomeProduct>> loadProducts() async {
    if (!isAvailable) return const [];

    try {
      final rows = await AgrisellSupabase.client.rpc<List<dynamic>>(
        'marketplace_products',
      );
      final commodities = await _withInventorySummaries(
        rows.whereType<Map<String, dynamic>>().toList(growable: false),
      );
      final farmsById = await _loadFarms(commodities);
      return commodities
          .map(
            (row) => productFromRow(
              row,
              farm: farmsById[HomeProductFormat.integer(row['farm_id'])],
            ),
          )
          .toList(growable: false);
    } on PostgrestException catch (error) {
      throw HomeProductException(error.message);
    }
  }

  Future<List<HomeProduct>> loadSaleCampaignProducts({
    required int saleId,
  }) async {
    if (!isAvailable || saleId <= 0) return const [];

    try {
      final rows = await AgrisellSupabase.client.rpc<List<dynamic>>(
        'marketplace_sale_campaign_products',
        params: {'p_sale_id': saleId},
      );
      final commodities = await _withInventorySummaries(
        rows.whereType<Map<String, dynamic>>().toList(growable: false),
      );
      final farmsById = await _loadFarms(commodities);
      return commodities
          .map(
            (row) => productFromRow(
              row,
              farm: farmsById[HomeProductFormat.integer(row['farm_id'])],
            ),
          )
          .toList(growable: false);
    } on PostgrestException catch (error) {
      throw HomeProductException(error.message);
    }
  }

  Future<List<HomeProduct>> loadProductsForFarm({
    required int farmId,
    required String sellerName,
    required String sellerLocation,
  }) async {
    if (!isAvailable || farmId <= 0) return const [];

    try {
      final rows = await AgrisellSupabase.client.rpc<List<dynamic>>(
        'marketplace_products',
        params: {'p_farm_id': farmId},
      );
      final farm = <String, dynamic>{
        'farmer_name': sellerName,
        'farm_location': sellerLocation,
      };
      final commodities = await _withInventorySummaries(
        rows.whereType<Map<String, dynamic>>().toList(growable: false),
      );
      return commodities
          .map((row) => productFromRow(row, farm: farm))
          .toList(growable: false);
    } on PostgrestException catch (error) {
      throw HomeProductException(error.message);
    }
  }

  Future<Map<int, Map<String, dynamic>>> _loadFarms(
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

  Future<List<Map<String, dynamic>>> _withInventorySummaries(
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

  static HomeProduct productFromRow(
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
      salePrice: _salePrice(row),
      unit: 'per ${HomeProductFormat.text(row['unit_type'], fallback: 'kg')}',
      image: _placeholderImage,
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

  static String? _salePrice(Map<String, dynamic> row) {
    final original = HomeProductFormat.number(row['price_per_unit']);
    final effective = HomeProductFormat.number(row['effective_price']);
    if (effective <= 0 || effective >= original) return null;
    return '₱${HomeProductFormat.displayNumber(row['effective_price'])}';
  }
}

class HomeProductException implements Exception {
  const HomeProductException(this.message);

  final String message;
}
