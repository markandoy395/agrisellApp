import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/buyer/cart/domain/checkout_voucher.dart';
import 'package:agresell_app/features/buyer/cart/domain/checkout_voucher_discount.dart';
import 'package:agresell_app/features/shared/orders/domain/basket_cart_item.dart';

export 'package:agresell_app/features/buyer/cart/domain/checkout_voucher.dart';

class CheckoutVoucherService {
  const CheckoutVoucherService({this.customValidator});

  final Future<AppliedVoucher> Function(
    String code,
    List<BasketCartItem> items,
  )?
  customValidator;

  Future<AppliedVoucher> validateVoucher({
    required String code,
    required List<BasketCartItem> items,
  }) async {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) {
      throw const VoucherValidationException('Please enter a voucher code.');
    }
    if (items.isEmpty) {
      throw const VoucherValidationException(
        'Select at least one item before applying a voucher.',
      );
    }

    if (customValidator != null) {
      return customValidator!(normalized, items);
    }

    if (!AgrisellSupabase.isInitialized) {
      throw const VoucherValidationException(
        'Vouchers are currently unavailable.',
      );
    }

    final client = AgrisellSupabase.client;
    try {
      final response = await client
          .from('product_sales')
          .select(
            'sale_id, name, promo_code, discount_type, discount_value, target_user_group, starts_at, ends_at, is_enabled',
          )
          .ilike('promo_code', normalized)
          .eq('is_enabled', true)
          .maybeSingle();

      if (response == null) {
        throw const VoucherValidationException(
          'Invalid or inactive voucher code.',
        );
      }

      final now = DateTime.now();
      final startsAtStr = response['starts_at'] as String?;
      final endsAtStr = response['ends_at'] as String?;

      if (startsAtStr != null &&
          DateTime.tryParse(startsAtStr)?.isAfter(now) == true) {
        throw const VoucherValidationException(
          'This voucher campaign has not started yet.',
        );
      }
      if (endsAtStr != null &&
          DateTime.tryParse(endsAtStr)?.isBefore(now) == true) {
        throw const VoucherValidationException(
          'This voucher code has expired.',
        );
      }

      final targetGroup =
          (response['target_user_group'] as String? ?? 'all_users')
              .toLowerCase();
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
      final discountValue =
          (response['discount_value'] as num?)?.toDouble() ?? 0.0;

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
      throw const VoucherValidationException(
        'Unable to validate voucher. Please try again.',
      );
    }
  }

  static double calculateDiscount({
    required List<BasketCartItem> items,
    required Set<int> applicableIds,
    required String discountType,
    required double discountValue,
  }) => calculateCheckoutVoucherDiscount(
    items: items,
    applicableIds: applicableIds,
    discountType: discountType,
    discountValue: discountValue,
  );

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
