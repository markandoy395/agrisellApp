import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String sql;

  setUpAll(() {
    sql = File(
      'supabase/migrations/20260810100000_restore_rider_live_locations.sql',
    ).readAsStringSync();
  });

  test('restores one secured current location row per Rider', () {
    expect(sql, contains('create table if not exists public.rider_locations'));
    expect(sql, contains('rider_id uuid not null unique'));
    expect(
      sql,
      contains('alter table public.rider_locations enable row level security'),
    );
    expect(sql, contains('identity.auth_user_id = (select auth.uid())'));
    expect(sql, contains('on conflict (rider_id) do nothing'));
  });

  test('allows an active Rider whose legacy users row is missing', () {
    expect(sql, contains('left join public.users as app_user'));
    expect(sql, contains('app_user.user_id is null'));
    expect(sql, contains("rider.employment_status = 'active'"));
    expect(sql, contains('lower(fulfillment.required_vehicle_type)'));
  });
}
