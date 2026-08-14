import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String sql;
  late String assignmentFoundation;

  setUpAll(() {
    sql = File(
      'supabase/migrations/'
      '20260811160000_offline_rider_booking_expiration.sql',
    ).readAsStringSync();
    assignmentFoundation = File(
      'supabase/migrations/20260802120000_add_farmer_selected_riders.sql',
    ).readAsStringSync();
  });

  test('permits structurally eligible offline Riders for manual requests', () {
    expect(sql, contains('private.rider_can_receive_manual_request'));
    expect(sql, contains("rider.availability_status = 'offline'"));
    expect(sql, contains("rider.employment_status = 'active'"));
    expect(sql, contains('private.rider_is_visible_for_delivery'));
    expect(sql, contains('private.rider_registered_service_area_contains'));
    expect(sql, contains("''online'', ''busy'', ''offline''"));
  });

  test('offline booking receives a server-owned 45-minute timeout', () {
    expect(sql, contains("then interval '45 minutes'"));
    expect(
      sql,
      contains('private.rider_assignment_request_timeout(p_rider_id)'),
    );
    expect(sql, contains("interval '60 minutes'"));
  });

  test('expiration releases only unanswered pending bookings', () {
    expect(sql, contains("where status = 'pending' and expires_at <= now()"));
    expect(sql, contains("set status = 'expired', responded_at = now()"));
    expect(sql, contains("'* * * * *'"));
    expect(sql, contains('cron.schedule'));
  });

  test('going offline does not fail or replace a pending booking early', () {
    final start = sql.indexOf(
      'create or replace function private.fail_rider_requests_when_unavailable',
    );
    final end = sql.indexOf('\ndo \$\$', start);
    final triggerFunction = sql.substring(start, end);
    expect(triggerFunction, contains('new.employment_status'));
    expect(triggerFunction, isNot(contains('new.availability_status')));
  });

  test('accepted requests are outside the expiration update', () {
    expect(sql, contains("where status = 'pending'"));
    expect(
      sql,
      isNot(contains("where status in ('pending', 'accepted') and expires_at")),
    );
    expect(
      assignmentFoundation,
      contains("set status = 'accepted', responded_at = now()"),
    );
  });

  test('selected offline Rider can accept through the locked transaction', () {
    expect(
      sql,
      contains("'private.accept_delivery(bigint,uuid)'::regprocedure"),
    );
    expect(sql, contains("'private.rider_can_receive_manual_request('"));
    expect(
      assignmentFoundation,
      contains('where delivery_id = p_delivery_id and rider_id = current_rider'),
    );
    expect(
      assignmentFoundation,
      contains('if selected_request.expires_at <= now() then'),
    );
  });
}
