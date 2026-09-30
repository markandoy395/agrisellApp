import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Verification Details SQL Contract Test', () {
    const migrationName =
        '20260919170000_add_verification_review_details_rpc.sql';

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

    test('migration defines rider and farmer verification RPCs', () {
      final sql = appMigration.readAsStringSync();

      expect(
        sql,
        contains('function private.current_rider_verification_details()'),
      );
      expect(
        sql,
        contains('function public.current_rider_verification_details()'),
      );
      expect(
        sql,
        contains('function private.current_farmer_verification_details()'),
      );
      expect(
        sql,
        contains('function public.current_farmer_verification_details()'),
      );
      expect(
        sql,
        contains(
          'grant execute on function public.current_rider_verification_details() to authenticated',
        ),
      );
      expect(
        sql,
        contains(
          'grant execute on function public.current_farmer_verification_details() to authenticated',
        ),
      );
      expect(sql, contains('from public.admin_verification_actions'));
      expect(sql, contains('from public.rider_documents'));
    });
  });
}
