import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String sql;

  setUpAll(() {
    sql = File(
      'supabase/migrations/20260811130000_add_atomic_product_restocking.sql',
    ).readAsStringSync().toLowerCase();
  });

  test('inventory can never become negative', () {
    expect(sql, contains('check (available_quantity >= 0)'));
    expect(sql, contains('alter column available_quantity set not null'));
  });

  test('zero and positive stock synchronize marketplace status', () {
    expect(sql, contains("new.commodity_status := 'out_of_stock'"));
    expect(sql, contains("new.commodity_status := 'available'"));
    expect(sql, contains('before insert or update of available_quantity'));
  });

  test('restocking locks one owned product and records an audit event', () {
    expect(sql, contains('for update;'));
    expect(sql, contains('private.owns_farm(commodity_record.farm_id)'));
    expect(sql, contains('previous_quantity + p_quantity'));
    expect(sql, contains('insert into private.commodity_restock_history'));
    expect(sql, contains('(select auth.uid())'));
  });

  test('sellers cannot bypass the atomic restock operation', () {
    expect(
      sql,
      contains(
        'revoke update (available_quantity) on public.commodities from authenticated',
      ),
    );
    expect(
      sql,
      contains(
        'grant execute on function public.restock_current_farmer_commodity',
      ),
    );
  });
}
