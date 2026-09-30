import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Customer Support Center SQL Contract Test', () {
    const migrationName =
        '20260919230000_add_customer_support_center.sql';

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

    test('migration defines customer support tables, functions, and RPCs', () {
      final sql = appMigration.readAsStringSync();

      expect(sql, contains('create table if not exists public.support_tickets'));
      expect(sql, contains('create table if not exists public.support_messages'));
      expect(sql, contains('function public.admin_get_support_hub'));
      expect(sql, contains('function public.admin_get_support_ticket_detail'));
      expect(sql, contains('function public.admin_send_support_message'));
      expect(sql, contains('function public.admin_update_support_ticket'));
      expect(sql, contains('function public.admin_create_support_ticket'));
      expect(sql, contains('function public.submit_customer_support_ticket'));
      expect(sql, contains('function public.current_user_support_tickets'));
      expect(sql, contains('function public.send_customer_support_message'));
    });
  });
}
