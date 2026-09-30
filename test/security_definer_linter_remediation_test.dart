import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Security Definer Linter Remediation Migration Contract', () {
    const migrationName =
        '20260925120000_harden_security_definer_rpcs_and_permissions.sql';

    final appMigration = File('supabase/migrations/$migrationName');
    final adminMigration = File(
      '../agrisellDashboard/agrisellAdmin/supabase/migrations/$migrationName',
    );

    test('migration exists in both app and admin repositories', () {
      expect(appMigration.existsSync(), isTrue,
          reason: 'Missing in agresellApp/supabase/migrations');
      expect(adminMigration.existsSync(), isTrue,
          reason:
              'Missing in agrisellDashboard/agrisellAdmin/supabase/migrations');
    });

    test('migration contents are synchronized', () {
      expect(
          appMigration.readAsStringSync(), adminMigration.readAsStringSync());
    });

    test('revokes execute from public, anon, and authenticated for all admin RPCs',
        () {
      final sql = appMigration.readAsStringSync().toLowerCase();

      const adminRpcs = [
        'public.admin_farmer_rider_requests',
        'public.admin_get_marketplace_conversation_detail',
        'public.admin_get_marketplace_conversations',
        'public.admin_get_payout_requests',
        'public.admin_get_support_hub',
        'public.admin_moderate_marketplace_conversation',
        'public.admin_resolve_safety_incident',
        'public.admin_safety_incidents',
        'public.admin_send_marketplace_intervention',
        'public.admin_update_payout_request',
      ];

      for (final rpc in adminRpcs) {
        expect(sql, contains(rpc),
            reason: '$rpc must be restricted in admin grants');
      }

      expect(sql, contains('from public, anon, authenticated'));
      expect(sql, contains('grant execute on function %s to service_role'));
    });

    test('hardens verification, dispute, reviews, payouts, sales, and safety RPCs',
        () {
      final sql = appMigration.readAsStringSync().toLowerCase();

      const clientRpcs = [
        'public.current_rider_verification_details()',
        'public.current_farmer_verification_details()',
        'public.farmer_resubmit_verification',
        'public.current_account_dispute_snapshots()',
        'public.current_farmer_reviews()',
        'public.current_user_payout_requests',
        'public.current_user_withdrawal_methods',
        'public.delete_user_withdrawal_method',
        'public.farmer_create_sale',
        'public.farmer_delete_sale',
        'public.farmer_load_sales',
        'public.farmer_update_sale',
        'public.get_my_safety_incidents',
        'public.marketplace_active_deals()',
        'public.marketplace_product_reviews',
        'public.report_current_buyer_order_dispute',
        'public.save_user_withdrawal_method',
        'public.submit_farmer_review_report_or_appeal',
        'public.submit_payout_request',
        'public.submit_safety_incident',
      ];

      for (final rpc in clientRpcs) {
        expect(sql, contains(rpc),
            reason: '$rpc must be included in client hardening');
      }

      expect(sql, contains('security invoker'));
      expect(sql, contains("set search_path = ''''"));
      expect(sql, contains("internal_name := 'api_impl_20260925_' || target_name"));
    });
  });
}
