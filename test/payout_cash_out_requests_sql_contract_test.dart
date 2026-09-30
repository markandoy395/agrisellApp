import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Payout and Cash-Out Requests SQL Migration Contract', () {
    test('both app and admin migrations exist and contain required tables and RPCs', () {
      final appMigration = File(
        'supabase/migrations/20260919240000_add_payout_cash_out_requests_rpc.sql',
      );
      final adminMigration = File(
        '../agrisellDashboard/agrisellAdmin/supabase/migrations/20260919240000_add_payout_cash_out_requests_rpc.sql',
      );

      expect(appMigration.existsSync(), isTrue,
          reason: 'App migration file must exist');
      expect(adminMigration.existsSync(), isTrue,
          reason: 'Admin migration file must exist');

      final appSql = appMigration.readAsStringSync();
      final adminSql = adminMigration.readAsStringSync();

      for (final sql in [appSql, adminSql]) {
        expect(sql, contains('user_withdrawal_methods'));
        expect(sql, contains('payout_requests'));
        expect(sql, contains('submit_payout_request'));
        expect(sql, contains('current_user_payout_requests'));
        expect(sql, contains('current_user_withdrawal_methods'));
        expect(sql, contains('save_user_withdrawal_method'));
        expect(sql, contains('delete_user_withdrawal_method'));
        expect(sql, contains('grant execute on function public.submit_payout_request'));
        expect(sql, contains('grant execute on function public.current_user_payout_requests'));
        expect(sql, contains('grant execute on function public.current_user_withdrawal_methods'));
        expect(sql, contains('grant execute on function public.save_user_withdrawal_method'));
        expect(sql, contains('grant execute on function public.delete_user_withdrawal_method'));
      }
    });
  });
}
