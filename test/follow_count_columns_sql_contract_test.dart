import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final migration = File(
    'supabase/migrations/20260731132000_ensure_follow_count_columns.sql',
  ).readAsStringSync();

  test('guarantees canonical follow counter columns exist', () {
    expect(migration, contains('add column if not exists follower_count'));
    expect(migration, contains('add column if not exists following_count'));
  });

  test('rebuilds counters from normalized follow relationships', () {
    expect(migration, contains('from public.farm_followers'));
    expect(migration, contains('set follower_count ='));
    expect(migration, contains('set following_count ='));
  });

  test('reloads the PostgREST schema cache', () {
    expect(migration, contains("notify pgrst, 'reload schema'"));
  });
}
