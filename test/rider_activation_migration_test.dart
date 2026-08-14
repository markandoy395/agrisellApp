import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String sql;

  setUpAll(() {
    sql = File(
      'supabase/migrations/'
      '20260810101000_fix_rider_live_location_and_activation.sql',
    ).readAsStringSync();
  });

  test('new Rider registrations are active but remain offline', () {
    expect(
      sql,
      contains("alter column employment_status set default 'active'"),
    );
    expect(sql, contains("'0, ''active'', null,'"));
    expect(sql, contains("availability_status = 'offline'"));
  });

  test('existing inactive registrations are activated', () {
    expect(sql, contains("where employment_status = 'inactive'"));
    expect(sql, isNot(contains("set employment_status = 'inactive'")));
  });
}
