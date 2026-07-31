import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final migration = File(
    'supabase/migrations/20260731130000_add_marketplace_farmer_following.sql',
  ).readAsStringSync();

  test('follow relationship prevents duplicate buyer and farm pairs', () {
    expect(migration, contains('create table public.farm_followers'));
    expect(migration, contains('primary key (buyer_user_id, farm_id)'));
    expect(migration, contains('on conflict (buyer_user_id, farm_id)'));
  });

  test('follow writes are buyer-scoped and exposed only through RPCs', () {
    expect(migration, contains('private.current_buyer_user_id()'));
    expect(migration, contains('set_marketplace_farmer_follow'));
    expect(
      migration,
      contains('revoke all on public.farm_followers from anon, authenticated'),
    );
    expect(migration, isNot(contains('grant insert on public.farm_followers')));
  });

  test('follow counters and directory state are synchronized', () {
    expect(migration, contains('farm_followers_refresh_counts'));
    expect(migration, contains('follower_count'));
    expect(migration, contains('following_count'));
    expect(migration, contains('marketplace_farmer_follow_states'));
    expect(migration, contains('current_profile_follow_stats'));
  });
}
