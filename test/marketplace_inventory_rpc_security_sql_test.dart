import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final migration = File(
    'supabase/migrations/'
    '20260828130000_harden_marketplace_inventory_rpcs.sql',
  );

  test('moves every reported RPC behind a security-invoker wrapper', () {
    final sql = migration.readAsStringSync().toLowerCase();
    const rpcNames = <String>[
      'marketplace_home_banners',
      'marketplace_inventory_lot_summaries',
      'marketplace_products',
      'marketplace_promotion_banners',
      'marketplace_sale_campaign_products',
      'restock_current_farmer_commodity',
      'restock_current_farmer_inventory_lot',
    ];

    for (final rpcName in rpcNames) {
      expect(
        sql,
        contains('public.$rpcName('),
        reason: '$rpcName must be included in the hardening migration',
      );
    }

    expect(sql, contains("internal_name := 'api_impl_20260828_'"));
    expect(sql, contains('security invoker'));
    expect(sql, contains("set search_path = ''''"));
  });

  test('preserves marketplace and farmer role boundaries', () {
    final sql = migration.readAsStringSync().toLowerCase();

    expect(
      sql,
      contains("allowed_roles := 'anon, authenticated, service_role'"),
    );
    expect(
      sql,
      contains("allowed_roles := 'authenticated, service_role'"),
    );
    expect(sql, contains("target_name like 'restock_current_farmer_%'"));
    expect(
      sql,
      contains(
        "'revoke all on function public.%i(%s) '"
        "\n      'from public, anon, authenticated, service_role'",
      ),
    );
  });

  test('preserves defaults relied on by existing clients', () {
    final sql = migration.readAsStringSync().toLowerCase();

    expect(sql, contains('p_farm_id bigint default null'));
    expect(
      sql,
      contains(
        'p_commodity_id bigint, p_quantity numeric, '
        'p_reason text default null',
      ),
    );
  });
}
