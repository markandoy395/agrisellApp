import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String sql;

  setUpAll(() {
    sql = File(
      'supabase/migrations/20260729120000_add_order_payments_reviews.sql',
    ).readAsStringSync();
  });

  test('checkout creates payment inside the stock reservation transaction', () {
    expect(
      sql,
      contains('create or replace function private.create_buyer_checkout'),
    );
    expect(sql, contains('insert into public.payments'));
    expect(sql, contains("requested_payment_status := case"));
    expect(sql, contains('set available_quantity = available_quantity -'));
    expect(
      sql.indexOf(
        'insert into public.payments',
        sql.indexOf('create or replace function private.create_buyer_checkout'),
      ),
      lessThan(sql.indexOf('set available_quantity = available_quantity -')),
    );
    expect(sql, contains("item ->> 'pricePerKg'"));
    expect(sql, contains('Refresh your basket before paying'));
    expect(sql, contains('delivery_latitude'));
    expect(sql, contains('delivery_longitude'));
    expect(sql, contains('private.seller_order_registry'));
  });

  test('GCash verification is farmer-owned and gates acceptance', () {
    expect(sql, contains('review_current_order_gcash_payment'));
    expect(sql, contains('orders_require_verified_gcash'));
    expect(sql, contains("new.payment_status is distinct from 'verified'"));
    expect(sql, contains("farmer.farmer_user_id = target_farmer_id"));
    expect(sql, contains('gcash_verified_reference_claims'));
    expect(sql, contains('already used for another order'));
  });

  test('rejected payment can be securely resubmitted by its buyer', () {
    expect(sql, contains('resubmit_current_order_gcash_reference'));
    expect(sql, contains("cart.buyer_user_id = target_buyer_id"));
    expect(sql, contains("payment_status = 'submitted_for_verification'"));
  });

  test('reviews require delivery and feed product and farmer aggregates', () {
    expect(sql, contains('sync_current_buyer_review_snapshots'));
    expect(sql, contains("incomplete_order.order_status <> 'delivered'"));
    expect(sql, contains('reviews_refresh_commodity_rating'));
    expect(sql, contains('marketplace_product_reviews'));
    expect(sql, contains('marketplace_farmer_directory'));
  });

  test('cancellation distinguishes unpaid and verified payments', () {
    expect(sql, contains('orders_sync_cancelled_payment'));
    expect(sql, contains("then 'refund_required' else 'cancelled'"));
    expect(sql, contains('record_current_order_gcash_refund'));
    expect(sql, contains("payment_status = 'refunded'"));
    expect(sql, contains('refund_reference'));
  });

  test('reviews and GCash settings are RPC-only mutations', () {
    expect(sql, contains('revoke update (rating, comment) on public.reviews'));
    expect(sql, contains('revoke update (bank_details) on public.farmers'));
  });
}
