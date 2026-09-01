import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final sql = File(
    'supabase/migrations/20260825150000_add_targeted_product_sales.sql',
  ).readAsStringSync();

  test('sales preserve base prices and support both user targets', () {
    expect(sql, contains('create table if not exists public.product_sales'));
    expect(sql, contains("'all_users', 'new_users_only'"));
    expect(sql, contains("'sale_price', 'percentage', 'amount'"));
    expect(sql, contains('private.is_new_buyer_sale_eligible'));
  });

  test('checkout ignores buyer-provided prices and persists server prices', () {
    expect(sql, contains("item.value - 'pricePerKg'"));
    expect(sql, contains('private.set_cart_item_effective_price'));
    expect(sql, contains('private.set_order_effective_total'));
    expect(sql, contains('private.set_payment_effective_amount'));
  });
}
