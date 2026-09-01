import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rider watchers subscribe to changes without discarded snapshots', () {
    final deliverySql = File(
      'lib/features/rider/deliveries/data/'
      'supabase_rider_delivery_repository.dart',
    ).readAsStringSync();
    final messageSql = File(
      'lib/features/rider/chat/data/supabase_rider_message_repository.dart',
    ).readAsStringSync();

    for (final source in [deliverySql, messageSql]) {
      expect(source, contains('.onPostgresChanges('));
      expect(source, contains('removeChannel(active)'));
      expect(source, isNot(contains('.stream(primaryKey:')));
    }
  });

  test('cron run history has bounded retention', () {
    final sql = File(
      'supabase/migrations/'
      '20260819101000_retain_recent_cron_run_history.sql',
    ).readAsStringSync().toLowerCase();

    expect(sql, contains("'agrisell-cron-run-history-retention'"));
    expect(sql, contains('delete from cron.job_run_details'));
    expect(sql, contains("interval '14 days'"));
  });
}
