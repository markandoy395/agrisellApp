import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('farmer requests require online fresh-location eligibility again', () {
    final sql = File(
      'supabase/migrations/'
      '20260808130000_rank_farmer_riders_by_current_location.sql',
    ).readAsStringSync();

    expect(sql, contains('pg_get_functiondef'));
    expect(sql, contains('private.rider_is_eligible_for_delivery'));
    expect(sql, contains("rider.availability_status = 'online'"));
    expect(sql, contains('private.rider_current_location_is_fresh'));
    expect(sql, contains('public.request_current_farmer_rider'));
  });
}
