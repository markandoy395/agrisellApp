import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Refunds and Payouts SQL Migration Contract', () {
    test('both app and admin migrations exist and contain required RPCs', () {
      final appMigration = File(
        'supabase/migrations/20260919160000_add_buyer_refunds_and_farmer_payouts_rpc.sql',
      );
      final adminMigration = File(
        '../agrisellDashboard/agrisellAdmin/supabase/migrations/20260919160000_add_buyer_refunds_and_farmer_payouts_rpc.sql',
      );

      expect(appMigration.existsSync(), isTrue,
          reason: 'App migration file must exist');
      expect(adminMigration.existsSync(), isTrue,
          reason: 'Admin migration file must exist');

      final appSql = appMigration.readAsStringSync();
      final adminSql = adminMigration.readAsStringSync();

      for (final sql in [appSql, adminSql]) {
        expect(sql, contains('current_account_refund_snapshots'));
        expect(sql, contains('current_farmer_payouts'));
        expect(sql, contains('private.owns_order'));
        expect(sql, contains('private.current_farmer_user_id()'));
        expect(sql, contains('private.farmer_payouts'));
        expect(sql, contains('private.payment_refunds'));
        expect(sql, contains('grant execute on function public.current_account_refund_snapshots() to authenticated;'));
        expect(sql, contains('grant execute on function public.current_farmer_payouts() to authenticated;'));
      }
    });
  });
}
