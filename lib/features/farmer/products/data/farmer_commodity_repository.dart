import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_context.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_format.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_mapper.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_write_values.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/shared/products/domain/product_sale_status.dart';
import 'package:agresell_app/features/shared/products/domain/product_inventory_lot.dart';
import 'package:agresell_app/features/shared/products/domain/product_availability_date_rules.dart';
import 'package:agresell_app/features/shared/products/domain/product_production_stage.dart';

class FarmerCommodityRepository {
  const FarmerCommodityRepository();

  static const _bucket = 'farmer-media';

  bool get isAvailable => AgrisellSupabase.isInitialized;

  Future<List<FarmerDashboardProduct>> loadProducts() async {
    if (!isAvailable) return const [];
    try {
      final context = await FarmerCommodityContext.load();
      final categories = await context.loadCategories();
      final response = await AgrisellSupabase.client
          .from('commodities')
          .select()
          .eq('farm_id', context.farmId)
          .order('created_at', ascending: false);
      final rows = (response as List).whereType<Map<String, dynamic>>().toList(
        growable: false,
      );
      final summaries = await _loadInventorySummaries(rows);
      final activeSales = await _loadActiveSalesForCommodities(rows);
      return rows
          .map((row) {
            final commodityId = FarmerCommodityFormat.integer(
              row['commodity_id'],
            );
            final summary = summaries[commodityId];
            final activeSale = activeSales[commodityId];
            return FarmerCommodityMapper.productFromRow(
              <String, dynamic>{
                ...row,
                if (summary != null) ...summary,
                if (summary != null)
                  'available_quantity': summary['marketable_quantity'],
                if (activeSale != null) ...activeSale,
              },
              categories,
              context.farmId,
            );
          })
          .toList(growable: false);
    } on PostgrestException catch (error) {
      throw FarmerCommodityException(
        FarmerCommodityFormat.databaseMessage(error.code, error.message),
      );
    }
  }

  Future<Map<int, Map<String, dynamic>>> _loadActiveSalesForCommodities(
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

  Future<FarmerDashboardProduct> save(FarmerDashboardProduct product) async {
    if (!isAvailable) return product;
    try {
      final context = await FarmerCommodityContext.load();
      if (product.commodityId == null && !context.isVerified) {
        throw const FarmerCommodityException(
          'Your farmer account is pending verification. You can add products after approval.',
        );
      }
      final categoryId = await context.resolveCategory(product.category);
      final imageUrl = await _imageUrlFor(product, context.authUserId);
      final values = _commodityValues(
        product,
        context.farmId,
        categoryId,
        imageUrl,
      );
      final isNewProduct = product.commodityId == null;
      final row = await _saveValues(product, context.farmId, values);
      final savedProduct = product.copyWith(
        commodityId: FarmerCommodityFormat.integer(row['commodity_id']),
        farmId: context.farmId,
        imageUrl: imageUrl,
      );
      if (!isNewProduct || product.availableQuantity <= 0) return savedProduct;
      return restock(
        product: savedProduct.copyWith(
          availableWeight: '0 ${product.unitType}',
        ),
        quantity: product.availableQuantity,
        inventoryLot: product.inventoryLot,
      );
    } on FarmerCommodityException {
      rethrow;
    } on PostgrestException catch (error) {
      throw FarmerCommodityException(
        FarmerCommodityFormat.databaseMessage(error.code, error.message),
      );
    } on StorageException {
      throw const FarmerCommodityException(
        'The product image could not be uploaded. Please try again.',
      );
    }
  }

  Future<FarmerDashboardProduct> restock({
    required FarmerDashboardProduct product,
    required double quantity,
    ProductInventoryLotDraft? inventoryLot,
    String? reason,
  }) async {
    final commodityId = product.commodityId;
    if (commodityId == null || commodityId <= 0) {
      throw const FarmerCommodityException(
        'Save this product before adding stock.',
      );
    }
    if (quantity <= 0 || quantity > 1000000) {
      throw const FarmerCommodityException(
        'Restock quantity must be between 0 and 1,000,000.',
      );
    }

    final lot = inventoryLot ?? product.inventoryLot;
    final lotErrors = lot.validationErrors(
      today: ProductAvailabilityDateRules.philippineToday(),
      allowFutureHarvest:
          product.productionStage != ProductProductionStage.harvested,
    );
    if (lotErrors.isNotEmpty) {
      throw FarmerCommodityException(lotErrors.values.first);
    }

    if (!isAvailable) {
      final updatedQuantity = product.availableQuantity + quantity;
      return product.copyWith(
        availableWeight:
            '${FarmerCommodityFormat.displayNumber(updatedQuantity)} ${product.unitType}',
        inventoryDateType: lot.dateType,
        harvestedAt: lot.harvestedAt,
        sellUntil: lot.sellUntil,
        expiresAt: lot.expiresAt,
        lotCode: lot.lotCode,
        storageInstructions: lot.storageInstructions,
      );
    }

    try {
      final result = await AgrisellSupabase.client.rpc<Object?>(
        'restock_current_farmer_inventory_lot',
        params: {
          'p_commodity_id': commodityId,
          'p_quantity': quantity,
          'p_date_type': lot.dateType.databaseValue,
          'p_harvested_at': _databaseDate(lot.harvestedAt),
          'p_sell_until': _databaseDate(lot.sellUntil),
          'p_expires_at': _databaseDate(lot.expiresAt),
          'p_lot_code': lot.lotCode?.trim(),
          'p_storage_instructions': lot.storageInstructions?.trim(),
          'p_reason': reason?.trim(),
        },
      );
      final row = result is Map
          ? Map<String, dynamic>.from(result)
          : const <String, dynamic>{};
      final newQuantity = FarmerCommodityFormat.displayNumber(
        row['new_quantity'],
      );
      return product.copyWith(
        availableWeight: '$newQuantity ${product.unitType}',
        inventoryDateType: lot.dateType,
        harvestedAt: lot.harvestedAt,
        sellUntil: lot.sellUntil,
        expiresAt: lot.expiresAt,
        lotCode: lot.lotCode,
        storageInstructions: lot.storageInstructions,
      );
    } on PostgrestException catch (error) {
      throw FarmerCommodityException(
        FarmerCommodityFormat.databaseMessage(error.code, error.message),
      );
    }
  }

  Future<void> createFarm(String name) async {
    if (!isAvailable) return;
    try {
      await FarmerCommodityContext.createFarm(name);
    } on FarmerCommodityException {
      rethrow;
    } on PostgrestException catch (error) {
      throw FarmerCommodityException(
        FarmerCommodityFormat.databaseMessage(error.code, error.message),
      );
    }
  }

  Future<String?> _imageUrlFor(
    FarmerDashboardProduct product,
    String authUserId,
  ) async {
    final bytes = product.imageBytes;
    if (bytes == null) return product.imageUrl;
    final identifier =
        product.commodityId?.toString() ??
        DateTime.now().microsecondsSinceEpoch.toString();
    final path = '$authUserId/commodities/$identifier.jpg';
    await AgrisellSupabase.client.storage
        .from(_bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );
    return AgrisellSupabase.client.storage.from(_bucket).getPublicUrl(path);
  }

  Map<String, Object?> _commodityValues(
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

  Future<Map<String, dynamic>> _saveValues(
    FarmerDashboardProduct product,
    int farmId,
    Map<String, Object?> values,
  ) {
    final commodities = AgrisellSupabase.client.from('commodities');
    return product.commodityId == null
        ? commodities
              .insert(<String, Object?>{...values, 'available_quantity': 0})
              .select()
              .single()
        : commodities
              .update(FarmerCommodityWriteValues.forUpdate(values))
              .eq('commodity_id', product.commodityId!)
              .eq('farm_id', farmId)
              .select()
              .single();
  }

  Future<Map<int, Map<String, dynamic>>> _loadInventorySummaries(
    List<Map<String, dynamic>> rows,
  ) async {
    if (rows.isEmpty) return const {};
    final ids = rows
        .map((row) => FarmerCommodityFormat.integer(row['commodity_id']))
        .toList(growable: false);
    final response = await AgrisellSupabase.client.rpc<List<dynamic>>(
      'marketplace_inventory_lot_summaries',
      params: {'p_commodity_ids': ids},
    );
    return {
      for (final row in response.whereType<Map<String, dynamic>>())
        FarmerCommodityFormat.integer(row['commodity_id']): row,
    };
  }

  static String? _databaseDate(DateTime? value) {
    if (value == null) return null;
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }
}
