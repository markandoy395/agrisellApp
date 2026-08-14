import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all local registered riders can receive a delivery request notification', () {
    final sql = File(
      'supabase/migrations/'
      '20260803190000_allow_notifications_to_all_local_riders.sql',
    ).readAsStringSync();

    expect(sql, contains('private.rider_can_receive_assignment_request'));
    expect(sql, contains('identity.auth_user_id is not null'));
    expect(sql, contains('public.request_current_farmer_rider'));
    expect(sql, isNot(contains("rider.availability_status = 'online'")));
  });
}
