import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_context.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_format.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_mapper.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_write_values.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/shared/products/domain/product_sale_status.dart';

class FarmerCommodityRepository {
  const FarmerCommodityRepository();

  static const _bucket = 'farmer-media';

  bool get isAvailable => AgrisellSupabase.isInitialized;

  Future<List<FarmerDashboardProduct>> loadProducts() async {
    if (!isAvailable) return const [];
    try {
      final context = await FarmerCommodityContext.load();
      final categories = await context.loadCategories();
      final rows = await AgrisellSupabase.client
          .from('commodities')
          .select()
          .eq('farm_id', context.farmId)
          .order('created_at', ascending: false);
      return (rows as List)
          .whereType<Map<String, dynamic>>()
          .map(
            (row) => FarmerCommodityMapper.productFromRow(
              row,
              categories,
              context.farmId,
            ),
          )
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
      final row = await _saveValues(product, context.farmId, values);
      return product.copyWith(
        commodityId: FarmerCommodityFormat.integer(row['commodity_id']),
        farmId: context.farmId,
        imageUrl: imageUrl,
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
  };

  Future<Map<String, dynamic>> _saveValues(
    FarmerDashboardProduct product,
    int farmId,
    Map<String, Object?> values,
  ) {
    final commodities = AgrisellSupabase.client.from('commodities');
    return product.commodityId == null
        ? commodities.insert(values).select().single()
        : commodities
              .update(FarmerCommodityWriteValues.forUpdate(values))
              .eq('commodity_id', product.commodityId!)
              .eq('farm_id', farmId)
              .select()
              .single();
  }
}
