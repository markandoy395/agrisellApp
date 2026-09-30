import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/shared/orders/domain/basket_cart_item.dart';

class AppliedVoucher {
  const AppliedVoucher({
    required this.saleId,
    required this.name,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.targetUserGroup,
    required this.discountAmount,
    required this.applicableCommodityIds,
  });

  final String saleId;
  final String name;
  final String code;
  final String discountType;
  final double discountValue;
  final String targetUserGroup;
  final double discountAmount;
  final Set<int> applicableCommodityIds;

  String get discountLabel {
    if (discountType == 'percentage') {
      final formatted = discountValue.toStringAsFixed(
        discountValue.truncateToDouble() == discountValue ? 0 : 2,
      );
      return '$formatted% OFF';
    }
    return '\u20b1${discountValue.toStringAsFixed(2)} OFF';
  }

  AppliedVoucher copyWithAmount(double newAmount) => AppliedVoucher(
    saleId: saleId,
    name: name,
    code: code,
    discountType: discountType,
    discountValue: discountValue,
    targetUserGroup: targetUserGroup,
    discountAmount: newAmount,
    applicableCommodityIds: applicableCommodityIds,
  );
}

class VoucherValidationException implements Exception {
  const VoucherValidationException(this.message);
  final String message;

  @override
  String toString() => message;
}

class CheckoutVoucherService {
  const CheckoutVoucherService({
    this.customValidator,
  });

  final Future<AppliedVoucher> Function(
    String code,
    List<BasketCartItem> items,
  )? customValidator;

  Future<AppliedVoucher> validateVoucher({
    required String code,
    required List<BasketCartItem> items,
  }) async {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) {
      throw const VoucherValidationException('Please enter a voucher code.');
    }
    if (items.isEmpty) {
      throw const VoucherValidationException('Select at least one item before applying a voucher.');
    }

    if (customValidator != null) {
      return customValidator!(normalized, items);
    }

    if (!AgrisellSupabase.isInitialized) {
      throw const VoucherValidationException('Vouchers are currently unavailable.');
    }

    final client = AgrisellSupabase.client;
    try {
      final response = await client
          .from('product_sales')
          .select('sale_id, name, promo_code, discount_type, discount_value, target_user_group, starts_at, ends_at, is_enabled')
          .ilike('promo_code', normalized)
          .eq('is_enabled', true)
          .maybeSingle();

      if (response == null) {
        throw const VoucherValidationException('Invalid or inactive voucher code.');
      }

      final now = DateTime.now();
      final startsAtStr = response['starts_at'] as String?;
      final endsAtStr = response['ends_at'] as String?;

      if (startsAtStr != null && DateTime.tryParse(startsAtStr)?.isAfter(now) == true) {
        throw const VoucherValidationException('This voucher campaign has not started yet.');
      }
      if (endsAtStr != null && DateTime.tryParse(endsAtStr)?.isBefore(now) == true) {
        throw const VoucherValidationException('This voucher code has expired.');
      }

      final targetGroup = (response['target_user_group'] as String? ?? 'all_users').toLowerCase();
      if (targetGroup == 'new_users_only') {
        final isEligible = await _checkNewUserEligibility(client);
        if (!isEligible) {
          throw const VoucherValidationException(
            'This voucher is valid for new users on their first order only.',
          );
        }
      }

      final saleId = response['sale_id'].toString();
      final itemsResponse = await client
          .from('product_sale_items')
          .select('commodity_id')
          .eq('sale_id', int.tryParse(saleId) ?? saleId);

      final applicableIds = (itemsResponse as List)
          .map((row) => (row as Map<String, dynamic>)['commodity_id'])
          .whereType<int>()
          .toSet();

      final discountType = response['discount_type'] as String? ?? 'percentage';
      final discountValue = (response['discount_value'] as num?)?.toDouble() ?? 0.0;

      final discountAmount = calculateDiscount(
        items: items,
        applicableIds: applicableIds,
        discountType: discountType,
        discountValue: discountValue,
      );

      if (discountAmount <= 0) {
        throw const VoucherValidationException(
          'None of the selected items are eligible for this voucher.',
        );
      }

      return AppliedVoucher(
        saleId: saleId,
        name: response['name'] as String? ?? 'Promo Discount',
        code: normalized,
        discountType: discountType,
        discountValue: discountValue,
        targetUserGroup: targetGroup,
        discountAmount: discountAmount,
        applicableCommodityIds: applicableIds,
      );
    } on VoucherValidationException {
      rethrow;
    } on PostgrestException catch (error) {
      throw VoucherValidationException(error.message);
    } catch (_) {
      throw const VoucherValidationException('Unable to validate voucher. Please try again.');
    }
  }

  static double calculateDiscount({
    required List<BasketCartItem> items,
    required Set<int> applicableIds,
    required String discountType,
    required double discountValue,
  }) {
    var discount = 0.0;
    var eligibleTotal = 0.0;

    for (final item in items) {
      final parsedId = int.tryParse(item.productId.trim());
      final isApplicable = applicableIds.isEmpty || (parsedId != null && applicableIds.contains(parsedId));
      if (!isApplicable) continue;

      final itemTotal = item.quantity * item.pricePerKg;
      eligibleTotal += itemTotal;

      if (discountType == 'percentage') {
        discount += itemTotal * (discountValue / 100);
      } else if (discountType == 'sale_price') {
        final originalTotal = itemTotal;
        final newTotal = item.quantity * discountValue;
        if (newTotal < originalTotal) {
          discount += (originalTotal - newTotal);
        }
      }
    }

    if (discountType == 'amount') {
      discount = min(eligibleTotal, discountValue);
    }

    return double.parse(discount.toStringAsFixed(2));
  }

  Future<bool> _checkNewUserEligibility(SupabaseClient client) async {
    try {
      final user = client.auth.currentUser;
      if (user == null) return false;

      final buyer = await client
          .from('buyers')
          .select('buyer_user_id')
          .eq('user_id', user.id)
          .maybeSingle();

      if (buyer == null) return false;
      final buyerId = buyer['buyer_user_id'];

      final orders = await client
          .from('orders')
          .select('order_id, carts!inner(buyer_user_id)')
          .eq('carts.buyer_user_id', buyerId)
          .limit(1);

      return (orders as List).isEmpty;
    } catch (_) {
      return false;
    }
  }
}
