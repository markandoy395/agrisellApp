import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final migration = File(
    'supabase/migrations/20260731131000_fix_farmer_follow_state_loading.sql',
  ).readAsStringSync();

  test('missing buyer identity returns an empty optional state set', () {
    expect(migration, contains('if current_buyer_id is null then'));
    expect(migration, contains('return;'));
    expect(migration, isNot(contains("raise exception 'Buyer account required'")));
  });

  test('follow-state RPC remains authenticated and security definer', () {
    expect(migration, contains('security definer'));
    expect(
      migration,
      contains(
        'grant execute on function public.marketplace_farmer_follow_states()',
      ),
    );
  });
}
