import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final sql = File(
    'supabase/migrations/20260827120000_add_promoted_sale_campaign_banners.sql',
  ).readAsStringSync();

  test('campaign banners are opt-in and grouped by sale', () {
    expect(sql, contains('promote_on_home boolean not null default false'));
    expect(sql, contains('where sale.promote_on_home'));
    expect(sql, contains('products.product_count > 1'));
    expect(sql, contains("'campaign:' || promotion.sale_id::text"));
    expect(sql, contains('where item.sale_id = sale.sale_id'));
  });

  test('manual and campaign banners use separate sources', () {
    expect(
      sql,
      contains('create table if not exists public.manual_home_banners'),
    );
    expect(sql, contains("'manual:' || manual.banner_id::text"));
    expect(sql, contains("'manual'::text"));
    expect(sql, contains("'campaign'::text"));
  });

  test('campaign products enforce dates, status, and buyer eligibility', () {
    expect(sql, contains('marketplace_sale_campaign_products'));
    expect(sql, contains('and sale.is_enabled'));
    expect(sql, contains('sale.ends_at > transaction_timestamp()'));
    expect(sql, contains('private.is_new_buyer_sale_eligible'));
  });
}
