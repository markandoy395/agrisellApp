import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/farmer/discounts/domain/farmer_discount.dart';

class FarmerDiscountRepository {
  const FarmerDiscountRepository({
    this.customDiscountsLoader,
    this.customDiscountCreator,
    this.customDiscountUpdater,
    this.customDiscountDeleter,
  });

  final Future<List<FarmerDiscount>> Function(int farmId)? customDiscountsLoader;
  final Future<int> Function({
    required int farmId,
    required String name,
    required String discountType,
    required double discountValue,
    DateTime? startsAt,
    DateTime? endsAt,
    String? promoCode,
    List<int> commodityIds,
  })? customDiscountCreator;
  final Future<void> Function({
    required int saleId,
    required int farmId,
    required String name,
    required String discountType,
    required double discountValue,
    DateTime? startsAt,
    DateTime? endsAt,
    String? promoCode,
    bool isEnabled,
    List<int> commodityIds,
  })? customDiscountUpdater;
  final Future<void> Function(int saleId, int farmId)? customDiscountDeleter;

  bool get isAvailable => AgrisellSupabase.isInitialized;

  Future<List<FarmerDiscount>> loadDiscounts(int farmId) async {
    if (customDiscountsLoader != null) {
      return customDiscountsLoader!(farmId);
    }
    if (!isAvailable) return const [];

    try {
      final rows = await AgrisellSupabase.client.rpc<List<dynamic>>(
        'farmer_load_sales',
        params: {'p_farm_id': farmId},
      );
      return rows
          .whereType<Map<String, dynamic>>()
          .map(FarmerDiscount.fromRow)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<int> createDiscount({
    required int farmId,
    required String name,
    required String discountType,
    required double discountValue,
    DateTime? startsAt,
    DateTime? endsAt,
    String? promoCode,
    List<int> commodityIds = const [],
  }) async {
    if (customDiscountCreator != null) {
      return customDiscountCreator!(
        farmId: farmId,
        name: name,
        discountType: discountType,
        discountValue: discountValue,
        startsAt: startsAt,
        endsAt: endsAt,
        promoCode: promoCode,
        commodityIds: commodityIds,
      );
    }
    if (!isAvailable) return 0;

    final response = await AgrisellSupabase.client.rpc<dynamic>(
      'farmer_create_sale',
      params: {
        'p_farm_id': farmId,
        'p_name': name,
        'p_discount_type': discountType,
        'p_discount_value': discountValue,
        'p_starts_at': startsAt?.toIso8601String(),
        'p_ends_at': endsAt?.toIso8601String(),
        'p_promo_code': promoCode,
        'p_commodity_ids': commodityIds,
      },
    );

    return (response as num?)?.toInt() ?? int.tryParse(response?.toString() ?? '') ?? 0;
  }

  Future<void> updateDiscount({
    required int saleId,
    required int farmId,
    required String name,
    required String discountType,
    required double discountValue,
    DateTime? startsAt,
    DateTime? endsAt,
    String? promoCode,
    bool isEnabled = true,
    List<int> commodityIds = const [],
  }) async {
    if (customDiscountUpdater != null) {
      return customDiscountUpdater!(
        saleId: saleId,
        farmId: farmId,
        name: name,
        discountType: discountType,
        discountValue: discountValue,
        startsAt: startsAt,
        endsAt: endsAt,
        promoCode: promoCode,
        isEnabled: isEnabled,
        commodityIds: commodityIds,
      );
    }
    if (!isAvailable) return;

    await AgrisellSupabase.client.rpc<void>(
      'farmer_update_sale',
      params: {
        'p_sale_id': saleId,
        'p_farm_id': farmId,
        'p_name': name,
        'p_discount_type': discountType,
        'p_discount_value': discountValue,
        'p_starts_at': startsAt?.toIso8601String(),
        'p_ends_at': endsAt?.toIso8601String(),
        'p_promo_code': promoCode,
        'p_is_enabled': isEnabled,
        'p_commodity_ids': commodityIds,
      },
    );
  }

  Future<void> deleteDiscount(int saleId, int farmId) async {
    if (customDiscountDeleter != null) {
      return customDiscountDeleter!(saleId, farmId);
    }
    if (!isAvailable) return;

    await AgrisellSupabase.client.rpc<void>(
      'farmer_delete_sale',
      params: {
        'p_sale_id': saleId,
        'p_farm_id': farmId,
      },
    );
  }
}
