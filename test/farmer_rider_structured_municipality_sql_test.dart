import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('eligible rider matching uses the structured municipality field', () {
    final sql = File(
      'supabase/migrations/'
      '20260803105000_match_riders_by_structured_municipality.sql',
    ).readAsStringSync();

    expect(sql, contains('rider.city_municipality'));
    expect(sql, contains('= lower(btrim(farm.city_municipality))'));
    expect(sql, contains('rider.location_label'));
    expect(sql, contains('array_to_string(company.service_areas'));
  });
}
