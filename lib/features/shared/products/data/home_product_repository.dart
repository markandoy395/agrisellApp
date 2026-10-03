import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/shared/products/data/home_product_data_hydrator.dart';
import 'package:agresell_app/features/shared/products/data/home_product_format.dart';
import 'package:agresell_app/features/shared/products/data/home_product_row_mapper.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';

class HomeProductRepository {
  const HomeProductRepository();

  bool get isAvailable => AgrisellSupabase.isInitialized;

  Future<List<HomeProduct>> loadProducts() async {
    return loadProductsChunk();
  }

  Future<List<HomeProduct>> loadProductsChunk({
    int? limit,
    int? offset,
  }) async {
    if (!isAvailable) return const [];

    try {
      final dynamic rawRows;
      if (limit != null) {
        final start = offset ?? 0;
        final end = start + limit - 1;
        rawRows = await AgrisellSupabase.client
            .rpc<List<dynamic>>('marketplace_products')
            .range(start, end);
      } else {
        rawRows = await AgrisellSupabase.client.rpc<List<dynamic>>(
          'marketplace_products',
        );
      }
      final rows = (rawRows as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);
      final commodities = await HomeProductDataHydrator.withInventorySummaries(
        rows,
      );
      final farmsById = await HomeProductDataHydrator.loadFarms(commodities);
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

  Future<({List<HomeProduct> products, bool hasMore})> loadProductsPage({
    int limit = 24,
    int offset = 0,
  }) async {
    if (runtimeType != HomeProductRepository) {
      final all = await loadProducts();
      if (offset >= all.length) {
        return (products: const <HomeProduct>[], hasMore: false);
      }
      final end = (offset + limit).clamp(0, all.length);
      final page = all.sublist(offset, end);
      return (products: page, hasMore: end < all.length);
    }

    if (!isAvailable) return (products: const <HomeProduct>[], hasMore: false);

    final fetched = await loadProductsChunk(
      limit: limit + 1,
      offset: offset,
    );
    final hasMore = fetched.length > limit;
    final pageProducts = hasMore
        ? fetched.take(limit).toList(growable: false)
        : fetched;
    return (products: pageProducts, hasMore: hasMore);
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
      final commodities = await HomeProductDataHydrator.withInventorySummaries(
        rows.whereType<Map<String, dynamic>>().toList(growable: false),
      );
      final farmsById = await HomeProductDataHydrator.loadFarms(commodities);
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
      final commodities = await HomeProductDataHydrator.withInventorySummaries(
        rows.whereType<Map<String, dynamic>>().toList(growable: false),
      );
      return commodities
          .map((row) => productFromRow(row, farm: farm))
          .toList(growable: false);
    } on PostgrestException catch (error) {
      throw HomeProductException(error.message);
    }
  }

  static HomeProduct productFromRow(
    Map<String, dynamic> row, {
    Map<String, dynamic>? farm,
  }) =>
      HomeProductRowMapper.fromRow(row, farm: farm);
}

class HomeProductException implements Exception {
  const HomeProductException(this.message);

  final String message;
}
