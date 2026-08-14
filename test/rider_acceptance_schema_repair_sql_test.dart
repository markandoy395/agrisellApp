import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final migration = File(
    'supabase/migrations/'
    '20260811173000_repair_rider_acceptance_schema_dependencies.sql',
  );

  test('acceptance validator runtime columns are repaired idempotently', () {
    final sql = migration.readAsStringSync().toLowerCase();

    expect(sql, contains('alter table public.deliveries'));
    expect(
      sql,
      contains('add column if not exists delivery_deadline timestamptz'),
    );
    expect(
      sql,
      contains('add column if not exists cold_chain_available boolean'),
    );
  });
}
