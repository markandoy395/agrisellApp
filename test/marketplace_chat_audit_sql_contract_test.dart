import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Admin Marketplace Chat Audit SQL Contract Test', () {
    const migrationName = '20260921100000_admin_marketplace_chat_audit.sql';

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

    test('migration defines moderation columns, RLS updates, and admin RPCs', () {
      final sql = appMigration.readAsStringSync().toLowerCase();

      expect(sql, contains('moderation_status text not null default \'active\''));
      expect(sql, contains('flag_reason text'));
      expect(sql, contains('moderation_notes text'));
      expect(sql, contains('or private.is_admin()'));
      expect(sql, contains('marketplace_conversations_admin_audit_read'));
      expect(sql, contains('marketplace_messages_admin_audit_read'));
      expect(sql, contains('function public.admin_get_marketplace_conversations'));
      expect(sql, contains('function public.admin_get_marketplace_conversation_detail'));
      expect(sql, contains('function public.admin_moderate_marketplace_conversation'));
      expect(sql, contains('function public.admin_send_marketplace_intervention'));
      expect(sql, contains('function public.admin_get_support_hub'));
    });
  });
}
