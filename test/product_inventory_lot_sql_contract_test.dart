import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String sql;

  setUpAll(() {
    sql = File(
      'supabase/migrations/20260828120000_add_batch_inventory_freshness.sql',
    ).readAsStringSync().toLowerCase();
  });

  test('stores freshness on inventory lots instead of product dates', () {
    expect(sql, contains('create table public.commodity_inventory_lots'));
    expect(sql, contains('quantity_remaining numeric(14,3)'));
    expect(sql, contains('sell_until date'));
    expect(sql, contains('expires_at date'));
    expect(sql, contains('lot_code text'));
    expect(sql, contains("'legacy_undated'"));
  });

  test('new edible stock requires its matching freshness fields', () {
    expect(sql, contains("p_date_type = 'fresh_produce'"));
    expect(sql, contains('p_sell_until is null'));
    expect(sql, contains("p_date_type = 'packaged_food'"));
    expect(sql, contains('p_expires_at is null'));
    expect(sql, contains('normalized_lot_code is null'));
    expect(
      sql,
      contains('edible products require freshness or expiration tracking'),
    );
  });

  test('checkout allocates earliest-expiring unexpired lots', () {
    expect(sql, contains('private.allocate_order_inventory_lots()'));
    expect(sql, contains('order_items_allocate_inventory_lots'));
    expect(
      sql,
      contains("coalesce(lot.expires_at, lot.sell_until, 'infinity'::date)"),
    );
    expect(sql, contains('this product no longer has enough unexpired stock'));
  });

  test('released orders restore their original lot only while valid', () {
    expect(sql, contains('private.release_order_inventory_lots()'));
    expect(sql, contains('orders_release_inventory_lots'));
    expect(sql, contains('allocated.released_at is null'));
    expect(sql, contains('allocation.sell_until >= current_date'));
  });

  test('marketplace and scheduled cleanup exclude expired quantities', () {
    expect(sql, contains('marketplace_inventory_lot_summaries'));
    expect(sql, contains('lot_summary.marketable_quantity > 0'));
    expect(sql, contains('private.expire_commodity_inventory_lots()'));
    expect(sql, contains("'agrisell-expire-inventory-lots'"));
  });

  test('lot and allocation tables are not directly exposed', () {
    expect(
      sql,
      contains(
        'revoke all on public.commodity_inventory_lots from public, anon, authenticated',
      ),
    );
    expect(
      sql,
      contains(
        'revoke all on private.order_inventory_lot_allocations\n  from public, anon, authenticated',
      ),
    );
  });
}
