import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_format.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/shared/products/domain/product_availability_date_rules.dart';
import 'package:agresell_app/features/shared/products/domain/product_inventory_lot.dart';
import 'package:agresell_app/features/shared/products/domain/product_production_stage.dart';

abstract final class FarmerCommodityRestockService {
  static Future<FarmerDashboardProduct> restock({
    required FarmerDashboardProduct product,
    required double quantity,
    required bool isAvailable,
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
          'p_harvested_at': databaseDate(lot.harvestedAt),
          'p_sell_until': databaseDate(lot.sellUntil),
          'p_expires_at': databaseDate(lot.expiresAt),
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

  static String? databaseDate(DateTime? value) {
    if (value == null) return null;
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }
}
