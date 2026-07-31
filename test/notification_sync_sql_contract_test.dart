import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String sql;

  setUpAll(() {
    sql = File(
      'supabase/migrations/20260730123000_add_fast_notification_sync.sql',
    ).readAsStringSync().toLowerCase();
  });

  test('active notification lookup is indexed and soft deletable', () {
    expect(sql, contains('add column if not exists deleted_at timestamptz'));
    expect(sql, contains('notifications_active_recipient_created_at_idx'));
    expect(sql, contains('where deleted_at is null'));
  });

  test('recipient updates remain protected by row-level security', () {
    expect(sql, contains('notifications_recipient_update'));
    expect(sql, contains('recipient_auth_user_id = (select auth.uid())'));
    expect(
      sql,
      contains('update (read_at, deleted_at) on public.notifications'),
    );
  });

  test('notifications are enabled for realtime delivery', () {
    expect(
      sql,
      contains(
        'alter publication supabase_realtime add table public.notifications',
      ),
    );
  });
}
