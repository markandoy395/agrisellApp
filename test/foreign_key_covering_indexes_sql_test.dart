import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Foreign Key Covering Indexes SQL Migration Contract', () {
    const migrationName =
        '20260925150000_add_foreign_key_covering_indexes.sql';

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

    test('defines covering indexes for all 29 flagged foreign keys', () {
      final sql = appMigration.readAsStringSync();

      const expectedIndexes = <String>[
        'admin_delivery_commands_delivery_id_idx',
        'admin_order_events_order_id_idx',
        'admin_payment_events_payment_id_idx',
        'commodity_restock_history_performed_by_idx',
        'delivery_cash_collections_rider_id_idx',
        'delivery_location_history_rider_id_idx',
        'farmer_payouts_farmer_user_id_idx',
        'gcash_verified_reference_claims_buyer_user_id_idx',
        'payment_refunds_payment_id_idx',
        'rider_delivery_limit_configuration_updated_by_idx',
        'seller_order_registry_buyer_user_id_idx',
        'seller_order_registry_seller_farm_id_idx',
        'admin_roles_user_id_idx',
        'buyers_user_id_idx',
        'categories_farm_id_idx',
        'commodity_inventory_lots_created_by_idx',
        'delivery_proofs_rider_id_idx',
        'farm_followers_farm_id_idx',
        'logistics_companies_delivery_id_idx',
        'marketplace_conversations_commodity_id_idx',
        'marketplace_conversations_farm_id_idx',
        'marketplace_conversations_order_id_idx',
        'payout_requests_user_id_idx',
        'reviews_buyer_user_id_idx',
        'reviews_commodity_id_idx',
        'reviews_farmer_user_id_idx',
        'rider_conversation_reads_delivery_id_idx',
        'rider_ratings_reviewer_auth_id_idx',
        'user_withdrawal_methods_user_id_idx',
      ];

      expect(expectedIndexes, hasLength(29));
      for (final idx in expectedIndexes) {
        expect(
          sql,
          contains(idx),
          reason: 'Expected index $idx to be defined in migration',
        );
      }
    });
  });
}
