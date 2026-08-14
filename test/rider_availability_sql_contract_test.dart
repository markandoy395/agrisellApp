import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String sql;

  setUpAll(() {
    sql = File(
      'supabase/migrations/20260808120000_update_current_rider_availability_rpc.sql',
    ).readAsStringSync();
  });

  test('updates only the authenticated Rider availability', () {
    expect(sql, contains('public.update_current_rider_availability'));
    expect(sql, contains('current_rider uuid := private.current_rider_id()'));
    expect(sql, contains("where rider_id = current_rider"));
    expect(sql, contains("set availability_status = normalized_status"));
  });

  test('keeps online and busy states active-rider only', () {
    expect(
      sql,
      contains("normalized_status not in ('offline', 'online', 'busy')"),
    );
    expect(sql, contains("target.employment_status, '') <> 'active'"));
    expect(sql, contains("Only an active Rider can go online"));
  });

  test('exposes the RPC only to authenticated users', () {
    expect(sql, contains('revoke all on function'));
    expect(sql, contains('from public, anon'));
    expect(sql, contains('grant execute'));
    expect(sql, contains('to authenticated'));
  });
}
