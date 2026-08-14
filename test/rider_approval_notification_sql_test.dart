import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String sql;

  setUpAll(() {
    sql = File(
      'supabase/migrations/20260811120000_add_rider_approval_notifications.sql',
    ).readAsStringSync();
  });

  test('notifies the Rider auth account when admin employment status changes', () {
    expect(
      sql,
      contains('private.notify_rider_employment_status_change()'),
    );
    expect(sql, contains('after update of employment_status on public.riders'));
    expect(sql, contains('identity.rider_id = new.rider_id'));
    expect(sql, contains("when 'active' then 'Rider account approved'"));
    expect(
      sql,
      contains(
        'You can now go online and accept delivery requests.',
      ),
    );
    expect(
      sql,
      contains("'verification_update',\n    'system',\n    'deliveries'"),
    );
  });

  test('backfills active Riders without duplicating approval notices', () {
    expect(sql, contains("where rider.employment_status = 'active'"));
    expect(sql, contains("notification.title = 'Rider account approved'"));
    expect(sql, contains("'backfilled', true"));
  });
}
