import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Database Performance Optimization Migration Contract', () {
    const migrationName =
        '20260925130000_optimize_database_performance_and_cron.sql';

    final appMigration = File('supabase/migrations/$migrationName');
    final adminMigration = File(
      '../agrisellDashboard/agrisellAdmin/supabase/migrations/$migrationName',
    );

    late String sql;

    setUpAll(() {
      sql = appMigration.readAsStringSync();
    });

    test('migration exists in both app and admin repositories', () {
      expect(appMigration.existsSync(), isTrue,
          reason: 'Missing in agresellApp/supabase/migrations');
      expect(adminMigration.existsSync(), isTrue,
          reason:
              'Missing in agrisellDashboard/agrisellAdmin/supabase/migrations');
    });

    test('migration contents are synchronized', () {
      expect(appMigration.readAsStringSync(), adminMigration.readAsStringSync());
    });

    test('indexes cron.job_run_details for fast retention deletion', () {
      expect(sql, contains('cron_job_run_details_end_time_idx'));
      expect(sql, contains('on cron.job_run_details (end_time)'));
    });

    test('adds short-circuit guards and partial indexes to rider cron jobs', () {
      expect(sql, contains('riders_active_online_idx'));
      expect(sql, contains('rider_locations_rider_updated_idx'));
      expect(sql, contains('rider_assignment_requests_pending_expiry_idx'));
      expect(sql, contains('availability_status = \'online\''));
      expect(sql, contains('employment_status = \'active\''));
      expect(sql, contains('return jsonb_build_object(\'expired\', 0);'));
    });

    test('adds fast guard conditions to order acceptance cron jobs', () {
      expect(sql, contains('orders_pending_halfway_reminder_idx'));
      expect(sql, contains('orders_pending_deadline_reminder_idx'));
      expect(sql, contains('return jsonb_build_object(\'reminders\', 0);'));
    });

    test('adds fast guard condition to commodity inventory lots expiration', () {
      expect(sql, contains('commodity_inventory_lots_expiring_idx'));
      expect(sql, contains('private.expire_commodity_inventory_lots()'));
    });

    test('optimizes rider dashboard to use pg_attribute instead of information_schema', () {
      expect(sql, contains('from pg_catalog.pg_attribute'));
      expect(sql, contains('attrelid = payment_table'));
      expect(sql, isNot(contains('from information_schema.columns')));
      expect(sql, contains('private.api_impl_current_rider_dashboard'));
      expect(sql, contains('public.current_rider_dashboard'));
    });

    test('creates composite indexes for delivery queries', () {
      expect(sql, contains('rider_delivery_assignments_rider_delivery_idx'));
      expect(sql, contains('deliveries_status_created_idx'));
    });
  });
}
