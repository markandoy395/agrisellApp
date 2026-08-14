import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String sql;

  setUpAll(() {
    sql = File(
      'supabase/migrations/'
      '20260809140000_show_non_nearby_rider_candidates.sql',
    ).readAsStringSync();
  });

  test('keeps service-area checks as request eligibility metadata', () {
    expect(sql, contains('private.rider_registered_service_area_contains'));
    expect(sql, contains('candidate.destination_supported'));
    expect(sql, contains('as destination_supported'));
  });

  test(
    'removes pickup and destination radius checks from directory filter',
    () {
      expect(sql, contains('regexp_replace'));
      expect(sql, contains('target.pickup_lat::double precision'));
      expect(sql, contains('target.dropoff_lat::double precision'));
      expect(sql, contains('directory still filters out non-nearby Riders'));
      expect(
        sql,
        contains(
          'do not use it\n'
          '-- to hide otherwise visible Rider profiles',
        ),
      );
    },
  );
}
