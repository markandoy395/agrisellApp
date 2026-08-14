import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final migration = File(
    'supabase/migrations/'
    '20260811172000_fix_rider_acceptance_deadline_validation.sql',
  );

  test('pending Rider requests use expiration as the acceptance deadline', () {
    final sql = migration.readAsStringSync().toLowerCase();

    expect(sql, contains('target_request.expires_at <= now()'));
    expect(sql, contains('target_delivery.delivery_deadline <= now()'));
    expect(sql, isNot(contains('target_request.requested_schedule <= now()')));
    expect(
      sql,
      isNot(contains('target_delivery.estimated_delivery_time <= now()')),
    );
    expect(
      sql,
      isNot(
        contains(
          'now() + make_interval(mins => active_minutes + 10)\n'
          '        > target_request.requested_schedule',
        ),
      ),
    );
  });
}
