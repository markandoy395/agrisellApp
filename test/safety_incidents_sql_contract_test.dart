import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Safety Incidents SQL Contract Test', () {
    const migrationName =
        '20260919180000_add_admin_safety_monitoring_rpc.sql';

    final appMigration = File('supabase/migrations/$migrationName');
    final adminMigration = File(
      '../agrisellDashboard/agrisellAdmin/supabase/migrations/$migrationName',
    );

    test('migration file exists in both app and admin dashboard', () {
      expect(
        appMigration.existsSync(),
        isTrue,
        reason: 'Missing in agresellApp/supabase/migrations',
      );
      expect(
        adminMigration.existsSync(),
        isTrue,
        reason:
            'Missing in agrisellDashboard/agrisellAdmin/supabase/migrations',
      );
    });

    test('migration contents are synchronized', () {
      expect(appMigration.readAsStringSync(), adminMigration.readAsStringSync());
    });

    test('migration defines admin safety incident RPCs and schema updates', () {
      final sql = appMigration.readAsStringSync();

      expect(
        sql,
        contains('alter table public.rider_incidents'),
      );
      expect(
        sql,
        contains('add column if not exists resolution_notes text'),
      );
      expect(
        sql,
        contains('add column if not exists resolved_by text'),
      );
      expect(
        sql,
        contains('add column if not exists resolved_at timestamptz'),
      );
      expect(
        sql,
        contains('function private.admin_safety_incidents('),
      );
      expect(
        sql,
        contains('function public.admin_safety_incidents('),
      );
      expect(
        sql,
        contains('function private.admin_resolve_safety_incident('),
      );
      expect(
        sql,
        contains('function public.admin_resolve_safety_incident('),
      );
      expect(
        sql,
        contains(
          'grant execute on function public.admin_safety_incidents(text, text, integer, integer) to authenticated;',
        ),
      );
      expect(
        sql,
        contains(
          'grant execute on function public.admin_resolve_safety_incident(text, text, text, text) to authenticated;',
        ),
      );
    });
  });
}
