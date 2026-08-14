import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rider directory displays all nearby profiles and marks requestable ones', () {
    final sql = File(
      'supabase/migrations/'
      '20260803170000_show_all_province_riders.sql',
    ).readAsStringSync();

    expect(sql, contains("'is_requestable', candidate.is_requestable"));
    expect(sql, contains('private.rider_is_eligible_for_delivery'));
    expect(sql, contains('from public.riders as rider'));
    expect(sql, isNot(contains("rider.employment_status = 'active'")));
  });
}
