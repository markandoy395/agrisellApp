import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_context.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_format.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_mapper.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_restock_service.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_sales_loader.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_write_values.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/shared/products/domain/product_inventory_lot.dart';

export 'package:agresell_app/features/farmer/products/data/farmer_commodity_format.dart';

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
      final activeSales = await FarmerCommoditySalesLoader.loadActiveSales(
        rows,
      );
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

  Future<FarmerDashboardProduct> save(FarmerDashboardProduct product) async {
    if (!isAvailable) return product;
    try {
      final context = await FarmerCommodityContext.load();
      if (product.commodityId == null && !context.canPostProducts) {
        throw const FarmerCommodityException(
          'Your farmer account cannot upload products. Please check your account status.',
        );
      }
      final categoryId = await context.resolveCategory(product.category);
      final imageUrl = await _imageUrlFor(product, context.authUserId);
      final values = FarmerCommodityWriteValues.commodityValues(
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
  }) => FarmerCommodityRestockService.restock(
    product: product,
    quantity: quantity,
    isAvailable: isAvailable,
    inventoryLot: inventoryLot,
    reason: reason,
  );

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
}
