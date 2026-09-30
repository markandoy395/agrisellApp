import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Database Linter Performance Remediation Migration Contract', () {
    const migrationName =
        '20260925140000_remediate_rls_initplan_and_permissive_policies.sql';

    final appMigration = File('supabase/migrations/$migrationName');
    final adminMigration = File(
      '../agrisellDashboard/agrisellAdmin/supabase/migrations/$migrationName',
    );

    test('migration exists in both app and admin dashboard', () {
      expect(
        appMigration.existsSync(),
        isTrue,
        reason: 'Missing in agresellApp/supabase/migrations',
      );
      expect(
        adminMigration.existsSync(),
        isTrue,
        reason: 'Missing in agrisellDashboard/agrisellAdmin/supabase/migrations',
      );
    });

    test('migration contents are synchronized', () {
      expect(
        appMigration.readAsStringSync(),
        adminMigration.readAsStringSync(),
      );
    });

    test('remediates auth_rls_initplan by wrapping auth.uid() in (select auth.uid())', () {
      final sql = appMigration.readAsStringSync();

      expect(sql, contains('public.user_withdrawal_methods'));
      expect(sql, contains('using ((select auth.uid()) = user_id)'));
      expect(sql, contains('with check ((select auth.uid()) = user_id)'));

      expect(sql, contains('public.payout_requests'));
      expect(sql, contains('create policy "Users can view own payout requests"'));
      expect(sql, contains('create policy "Users can create own payout requests"'));

      // Ensure no un-wrapped auth.uid() = user_id exists in the migration
      expect(
        RegExp(r'(?<!\(select\s)auth\.uid\(\)\s*=\s*user_id').hasMatch(sql),
        isFalse,
        reason: 'All auth.uid() calls must be wrapped in (select auth.uid())',
      );
    });

    test('remediates multiple_permissive_policies for marketplace conversations and messages', () {
      final sql = appMigration.readAsStringSync();

      expect(sql, contains('drop policy if exists marketplace_conversations_admin_audit_read'));
      expect(sql, contains('drop policy if exists marketplace_messages_admin_audit_read'));
      expect(sql, contains('create policy marketplace_conversations_participant_read'));
      expect(sql, contains('create policy marketplace_messages_participant_read'));
      expect(sql, contains('(select private.is_admin())'));
    });

    test('remediates multiple_permissive_policies for rider_incidents', () {
      final sql = appMigration.readAsStringSync();

      expect(sql, contains('drop policy if exists rider_incidents_reporter_read'));
      expect(sql, contains('drop policy if exists rider_incidents_reporter_insert'));
      expect(sql, contains('create policy authenticated_select'));
      expect(sql, contains('create policy authenticated_insert'));
      expect(sql, contains('reporter_auth_id = (select auth.uid())'));
    });
  });
}
