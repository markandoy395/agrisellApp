import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agresell_app/core/services/gateway_rpc.dart';
import 'farmer_commodity_context.dart';
import 'farmer_commodity_format.dart';
import 'farmer_commodity_restock_service.dart';
import 'farmer_commodity_write_values.dart';
import '../domain/farmer_dashboard_product.dart';

class FarmerProductPublisher {
  const FarmerProductPublisher(
    this.client, {
    this.loadContext = FarmerCommodityContext.load,
  });
  final SupabaseClient client;
  final Future<FarmerCommodityContext> Function() loadContext;

  static String newRequestKey() {
    final random = Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 15) | 64;
    bytes[8] = (bytes[8] & 63) | 128;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  Future<FarmerDashboardProduct> publish(
    FarmerDashboardProduct product,
    String requestKey,
  ) async {
    final context = await loadContext();
    if (!context.isVerified) {
      throw const FarmerCommodityException(
        'Farmer approval is required to publish.',
      );
    }
    final bytes = product.imageBytes;
    if (bytes == null) {
      throw const FarmerCommodityException(
        'Add a product photo before publishing.',
      );
    }
    final imageHash = sha256.convert(bytes).toString();
    final path = '${context.authUserId}/commodities/$requestKey-$imageHash.jpg';
    final bucket = client.storage.from('farmer-media');
    final imageUrl = bucket.getPublicUrl(path);
    final lot = product.inventoryLot;
    final values = FarmerCommodityWriteValues.commodityValues(
      product,
      context.farmId,
      0,
      imageUrl,
    )..remove('category_id');
    values['category_name'] = product.category;
    try {
      await bucket.uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
      );
      final result = await GatewayRpc.call(
        client,
        'publish_current_farmer_product',
        {
          'p_request_key': requestKey,
          'p_product': values,
          'p_lot': {
            'date_type': lot.dateType.databaseValue,
            'harvested_at': FarmerCommodityRestockService.databaseDate(
              lot.harvestedAt,
            ),
            'sell_until': FarmerCommodityRestockService.databaseDate(
              lot.sellUntil,
            ),
            'expires_at': FarmerCommodityRestockService.databaseDate(
              lot.expiresAt,
            ),
            'lot_code': lot.lotCode,
            'storage_instructions': lot.storageInstructions,
          },
        },
      );
      if (client.auth.currentUser?.id != context.authUserId) {
        throw const FarmerCommodityException(
          'Sign in again to reload your products.',
        );
      }
      final row = Map<String, dynamic>.from(result as Map);
      return product.copyWith(
        commodityId: FarmerCommodityFormat.integer(row['commodity_id']),
        farmId: context.farmId,
        imageUrl: row['image_url'] as String?,
        availableWeight: '${row['available_quantity']} ${product.unitType}',
      );
    } on PostgrestException catch (error) {
      // A lost response may represent a committed publication. Retain its image
      // for the same-key retry; only clean up definite, unreferenced rejections.
      if (const {
        '22023',
        '23514',
        '42501',
        '23503',
        '22P02',
        '22003',
        '23502',
      }.contains(error.code)) {
        await _removeUnreferencedImage(context.authUserId, path, imageUrl);
      }
      throw FarmerCommodityException(
        error.code == '22023' && error.message.contains('retry key')
            ? 'This listing was already published. Refresh your products before making changes.'
            : FarmerCommodityFormat.databaseMessage(error.code, error.message),
      );
    } on StorageException {
      throw const FarmerCommodityException(
        'The product photo could not be uploaded. Please retry.',
      );
    }
  }

  Future<void> _removeUnreferencedImage(
    String owner,
    String path,
    String url,
  ) async {
    try {
      if (client.auth.currentUser?.id != owner) return;
      final rows = await client
          .from('commodities')
          .select('commodity_id')
          .eq('image_url', url)
          .limit(1);
      if (rows.isEmpty && client.auth.currentUser?.id == owner) {
        await client.storage.from('farmer-media').remove([path]);
      }
    } catch (_) {
      // Cleanup failure must not replace the original publication error.
    }
  }
}
