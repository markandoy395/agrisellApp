import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String sql;

  setUpAll(() {
    sql = File(
      'supabase/migrations/'
      '20260811150000_list_all_eligible_riders_nearest_first.sql',
    ).readAsStringSync();
  });

  test('returns only Riders able to receive the delivery', () {
    expect(sql, contains('private.rider_is_visible_for_delivery'));
    expect(sql, contains('private.rider_is_eligible_for_delivery'));
    expect(sql, contains("rider.employment_status = 'active'"));
    expect(sql, contains("rider.availability_status in ('online', 'busy')"));
    expect(sql, contains('where candidate.is_requestable'));
    expect(sql, contains('and candidate.destination_supported'));
  });

  test('orders every eligible Rider nearest to farthest', () {
    expect(sql, contains('order by candidate.distance_km asc nulls last'));
    expect(sql, contains('private.rider_distance_from_registered_location_km'));
    expect(
      RegExp(r'\blimit\s+\d', caseSensitive: false).hasMatch(sql),
      isFalse,
    );
  });

  test('does not use distance as a directory filter', () {
    final candidateFilter = sql.substring(sql.indexOf(') as candidate'));
    expect(candidateFilter, contains('where candidate.is_requestable'));
    expect(candidateFilter, isNot(contains('candidate.distance_km <')));
    expect(candidateFilter, isNot(contains('candidate.distance_km <=')));
  });
}
