import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rider map discovery is bounded behind existing authorization', () {
    final sql = File(
      'supabase/migrations/20260819090000_add_bounded_rider_map_discovery.sql',
    ).readAsStringSync().toLowerCase();

    expect(sql, contains('private.current_rider_deliveries(true)'));
    expect(sql, contains('private.geo_distance_km'));
    expect(sql, contains('where assigned or distance_km <= rider_radius_km'));
    expect(sql, contains('limit result_limit'));
    expect(sql, contains('from public.riders as rider'));
    expect(sql, contains('to authenticated'));
    expect(sql, contains('from public, anon'));
  });

  test('nearby farms expose only verified public farm fields', () {
    final sql = File(
      'supabase/migrations/20260819104000_fix_rider_nearby_farms_radius.sql',
    ).readAsStringSync().toLowerCase();

    expect(sql, contains("rider.employment_status) = 'active'"));
    expect(sql, isNot(contains('rider.verification_status')));
    expect(sql, isNot(contains('rider.service_radius_km')));
    expect(sql, contains('least(greatest(p_radius_km, 0.5), 100)'));
    expect(sql, contains("verification_status, 'pending')) = 'verified'"));
    expect(sql, contains("account_status, 'active')) = 'active'"));
    expect(sql, contains('private.geo_distance_km'));
    expect(sql, contains('farm.gps_lat'));
    expect(sql, contains('farm.gps_long'));
    expect(sql, isNot(contains('phone_number')));
    expect(sql, isNot(contains('auth_user_id')));
    expect(sql, contains('from public, anon'));
    expect(sql, contains('to authenticated'));
  });
}
