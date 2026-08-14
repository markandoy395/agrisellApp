import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final migration = File(
    'supabase/migrations/'
    '20260811180000_harden_exposed_security_definer_rpcs.sql',
  );

  test('moves every reported privileged RPC behind an invoker wrapper', () {
    final sql = migration.readAsStringSync().toLowerCase();
    const rpcNames = <String>[
      'accept_delivery',
      'cancel_current_farmer_order',
      'cancel_current_farmer_rider_request',
      'checkout_gcash_details',
      'complete_pickup',
      'configure_rider_delivery_limit',
      'current_account_cancellation_snapshots',
      'current_farmer_rider_assignment_requests',
      'current_marketplace_conversations',
      'current_profile_follow_stats',
      'current_rider_conversation_messages',
      'current_rider_conversations',
      'current_rider_dashboard',
      'current_rider_ratings',
      'decline_delivery_request',
      'eligible_riders_for_current_farmer_order',
      'mark_current_farmer_order_ready',
      'mark_current_rider_conversation_read',
      'mark_marketplace_conversation_read',
      'marketplace_conversation_messages',
      'marketplace_farm_details',
      'marketplace_farmer_directory',
      'marketplace_farmer_follow_state',
      'marketplace_farmer_follow_states',
      'marketplace_product_reviews',
      'request_current_farmer_rider',
      'restock_current_farmer_commodity',
      'save_current_rider_confirmation_code',
      'save_current_rider_delivery_proof',
      'send_marketplace_message',
      'send_rider_delivery_message',
      'set_marketplace_farmer_follow',
      'start_marketplace_conversation',
      'submit_current_buyer_feedback',
      'submit_rider_rating',
      'update_current_rider_availability',
      'update_delivery_status',
    ];

    expect(rpcNames, hasLength(37));
    for (final rpcName in rpcNames) {
      expect(
        sql,
        contains('public.$rpcName('),
        reason: '$rpcName must be included in the hardening migration',
      );
    }

    expect(sql, contains("internal_name := 'api_impl_' || target_name"));
    expect(sql, contains('security invoker'));
    expect(sql, contains("set search_path = ''''"));
    expect(
      sql,
      contains(
        'grant execute on function public.%i(%s) '
        'to authenticated, service_role',
      ),
    );
    expect(
      sql,
      contains(
        'revoke execute on functions from public, anon, authenticated, '
        'service_role',
      ),
    );
  });

  test('keeps anonymous users away from both wrapper and implementation', () {
    final sql = migration.readAsStringSync().toLowerCase();

    expect(
      sql,
      contains(
        "'revoke all on function private.%i(%s) '"
        "\n      'from public, anon, authenticated, service_role'",
      ),
    );
    expect(
      sql,
      contains(
        "'revoke all on function public.%i(%s) '"
        "\n      'from public, anon, authenticated, service_role'",
      ),
    );
  });

  test('installs pg_net outside public for fresh databases', () {
    final sourceMigration = File(
      'supabase/migrations/'
      '20260730131000_dispatch_fcm_notifications.sql',
    ).readAsStringSync().toLowerCase();
    final remediation = migration.readAsStringSync().toLowerCase();

    expect(
      sourceMigration,
      contains('create extension if not exists pg_net with schema extensions'),
    );
    expect(
      remediation,
      contains('alter extension pg_net set schema extensions'),
    );
    expect(remediation, contains('pg_net_is_relocatable'));
  });

  test('documents deny-only RLS policies for every internal table', () {
    final sql = File(
      'supabase/migrations/'
      '20260811181000_document_internal_table_deny_policies.sql',
    ).readAsStringSync().toLowerCase();
    const internalTables = <String>[
      'private.auth_identities',
      'private.commodity_restock_history',
      'private.delivery_cash_collections',
      'private.delivery_status_events',
      'private.gcash_verified_reference_claims',
      'private.order_acceptance_events',
      'private.order_checkout_keys',
      'private.order_delivery_fulfillments',
      'private.rider_delivery_assignments',
      'private.seller_order_registry',
      'public.farm_followers',
    ];

    expect(internalTables, hasLength(11));
    for (final table in internalTables) {
      expect(
        sql,
        contains('on $table\nas restrictive'),
        reason: '$table must have an explicit restrictive RLS policy',
      );
      expect(
        sql,
        contains(
          'revoke all privileges on table $table\n'
          '  from public, anon, authenticated',
        ),
        reason: '$table must not be directly accessible to Data API roles',
      );
    }

    expect(
      RegExp(r'create policy "deny direct client access"')
          .allMatches(sql),
      hasLength(11),
    );
    expect(RegExp(r'using \(false\)').allMatches(sql), hasLength(11));
    expect(RegExp(r'with check \(false\)').allMatches(sql), hasLength(11));
  });

  test('reinstalls non-relocatable pg_net only with an empty queue', () {
    final sql = File(
      'supabase/migrations/'
      '20260811182000_reinstall_pg_net_outside_public.sql',
    ).readAsStringSync().toLowerCase();

    expect(
      sql,
      contains(
        'lock table net.http_request_queue in access exclusive mode nowait',
      ),
    );
    expect(
      sql,
      contains('select exists (select 1 from net.http_request_queue)'),
    );
    expect(sql, contains("execute 'drop extension pg_net'"));
    expect(
      sql,
      contains(
        "'create extension pg_net with schema extensions version %l'",
      ),
    );
    expect(sql, isNot(contains('drop extension pg_net cascade')));
    expect(
      sql,
      contains("if installed_schema is distinct from 'extensions' then"),
    );
  });
}
