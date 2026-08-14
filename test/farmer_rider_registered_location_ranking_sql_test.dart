import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String sql;

  setUpAll(() {
    sql = File(
      'supabase/migrations/'
      '20260810102000_rank_farmer_riders_by_registered_location.sql',
    ).readAsStringSync();
  });

  test('calculates Farmer distance from Rider signup coordinates', () {
    expect(sql, contains('private.rider_distance_from_registered_location_km'));
    expect(sql, contains('rider.gps_lat::double precision'));
    expect(sql, contains('rider.gps_long::double precision'));
    expect(sql, contains('private.geo_distance_km'));
  });

  test('patches the Farmer directory away from live GPS ranking', () {
    expect(sql, contains('pg_get_functiondef'));
    expect(
      sql,
      contains(
        "'private.rider_distance_from_current_location_km(',\n"
        "    'private.rider_distance_from_registered_location_km('",
      ),
    );
    expect(sql, contains('Farmer Rider directory still depends on live GPS'));
  });

  test('keeps Online and registered route coverage request checks', () {
    expect(sql, contains("rider.availability_status = 'online'"));
    expect(sql, contains('private.rider_registered_location_is_available'));
    expect(sql, contains('private.rider_registered_service_area_contains'));
    expect(
      sql,
      isNot(contains("and private.rider_current_location_is_fresh(")),
    );
  });
}
