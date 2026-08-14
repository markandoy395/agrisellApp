import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('offline riders are visible while request eligibility remains online-only', () {
    final sql = File(
      'supabase/migrations/'
      '20260803160000_show_offline_rider_candidates.sql',
    ).readAsStringSync();

    expect(sql, contains('private.rider_is_visible_for_delivery'));
    expect(sql, isNot(contains("rider.availability_status = 'online'")));
    expect(sql, contains("'availability_status', candidate.availability_status"));
  });
}
