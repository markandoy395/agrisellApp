import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final migration = File(
    'supabase/migrations/'
    '20260819100000_consolidate_authenticated_rls_policies.sql',
  );

  test('consolidates every table reported by the Supabase policy linter', () {
    final sql = migration.readAsStringSync().toLowerCase();
    const tables = <String>[
      'buyers',
      'cart_items',
      'carts',
      'categories',
      'commodities',
      'deliveries',
      'delivery_proofs',
      'farmers',
      'farms',
      'logistics_companies',
      'order_items',
      'orders',
      'payments',
      'reviews',
      'rider_documents',
      'rider_incidents',
      'users',
    ];

    expect(tables, hasLength(17));
    for (final table in tables) {
      expect(
        sql,
        contains("    '$table'"),
        reason: '$table must have its authenticated policies consolidated',
      );
    }
  });

  test('retains permissive OR semantics with one policy per SQL action', () {
    final sql = migration.readAsStringSync().toLowerCase();

    expect(sql, contains("and permissive = 'permissive'"));
    expect(sql, contains("roles = array['authenticated']::name[]"));
    expect(sql, contains("cmd in ('all', 'select')"));
    expect(sql, contains("cmd in ('all', 'insert')"));
    expect(sql, contains("cmd in ('all', 'update')"));
    expect(sql, contains("cmd in ('all', 'delete')"));
    expect(sql, contains("' or ' order by policyname"));
    expect(sql, contains('coalesce(with_check, qual, \'true\')'));
    expect(sql, contains('create policy authenticated_select'));
    expect(sql, contains('create policy authenticated_insert'));
    expect(sql, contains('create policy authenticated_update'));
    expect(sql, contains('create policy authenticated_delete'));
  });
}
