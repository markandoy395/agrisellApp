import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String sql;
  late String permissionFix;
  late String authorizationHardening;
  late String permissionReapply;
  late String deliveryPaymentsRepair;

  setUpAll(() {
    sql = File(
      'supabase/migrations/20260811170000_farmer_order_cancellation.sql',
    ).readAsStringSync();
    permissionFix = File(
      'supabase/migrations/'
      '20260811171000_fix_farmer_order_cancellation_permissions.sql',
    ).readAsStringSync();
    authorizationHardening = File(
      'supabase/migrations/'
      '20260811176000_harden_farmer_order_cancellation_authorization.sql',
    ).readAsStringSync();
    permissionReapply = File(
      'supabase/migrations/'
      '20260811177000_reapply_farmer_order_cancellation_rpc.sql',
    ).readAsStringSync();
    deliveryPaymentsRepair = File(
      'supabase/migrations/'
      '20260811178000_repair_delivery_payments_relation.sql',
    ).readAsStringSync();
  });

  test('server authenticates the farmer and requires a reason', () {
    expect(sql, contains('private.current_farmer_user_id()'));
    expect(sql, contains('farm.farmer_user_id = current_farmer'));
    expect(sql, contains('Select a valid cancellation reason'));
    expect(sql, contains("cancelled_by_role = 'farmer'"));
    expect(sql, contains('cancelled_by_auth_user_id = current_auth_user'));
    expect(sql, contains('cancelled_at = cancelled_time'));
  });

  test('allows active states but blocks pickup and terminal states', () {
    expect(sql, contains("'preparing', 'readyForPickup'"));
    expect(sql, contains("'accepted', 'going_to_pickup'"));
    expect(sql, contains("'arrived_at_pickup'"));
    expect(sql, contains('already been picked up'));
    expect(sql, contains("'delivered', 'completed', 'cancelled'"));
  });

  test('cancellation atomically releases stock, request, and rider', () {
    expect(sql, contains('set available_quantity = available_quantity +'));
    expect(sql, contains("set delivery_status = 'cancelled'"));
    expect(sql, contains("and status in ('pending', 'accepted')"));
    expect(sql, contains('delete from private.rider_delivery_assignments'));
    expect(sql, contains("then 'busy' else 'online' end"));
    expect(sql, contains("set earning_status = 'cancelled'"));
  });

  test('records audit metadata and notifies affected accounts', () {
    expect(sql, contains("'farmer_cancelled'"));
    expect(sql, contains("'cancellation_reason', clean_reason"));
    expect(sql, contains("'cancelled_by', 'farmer'"));
    expect(sql, contains("'cancelled_at', cancelled_time"));
    expect(sql, contains("'order_cancelled'"));
    expect(sql, contains('private.delivery_status_events'));
  });

  test('exposes cancellation snapshots to buyer and farmer state', () {
    expect(sql, contains('current_account_cancellation_snapshots'));
    expect(sql, contains("'cancellationReason', cancellation_reason"));
    expect(sql, contains("'cancelledBy', cancelled_by"));
    expect(sql, contains("'cancelledAt', cancelled_at"));
  });

  test('public wrappers can execute while private functions stay locked', () {
    expect(
      permissionFix,
      contains(
        'public.cancel_current_farmer_order(\n'
        '  p_seller_order_id text,',
      ),
    );
    expect(permissionFix, contains('security definer'));
    expect(permissionFix, contains('from public, anon, authenticated;'));
    expect(permissionFix, contains('to authenticated;'));
    expect(permissionFix, contains("notify pgrst, 'reload schema'"));
  });

  test('authorization hardening prevents invoker and SQL-inline failures', () {
    expect(authorizationHardening, contains('language plpgsql'));
    expect(authorizationHardening, contains('security definer'));
    expect(
      authorizationHardening,
      contains('private.cancel_current_farmer_order(text, text)'),
    );
    expect(
      authorizationHardening,
      contains('private.current_account_cancellation_snapshots()'),
    );
    expect(authorizationHardening, contains('to authenticated;'));
  });

  test('latest repair reapplies and verifies the authenticated RPC grant', () {
    expect(permissionReapply, contains('language plpgsql'));
    expect(permissionReapply, contains('security definer'));
    expect(permissionReapply, contains('owner to postgres'));
    expect(
      permissionReapply,
      contains("'public.cancel_current_farmer_order(text,text)'"),
    );
    expect(permissionReapply, contains('has_function_privilege'));
    expect(permissionReapply, contains('to authenticated;'));
    expect(permissionReapply, contains("notify pgrst, 'reload schema'"));
  });

  test('repairs the delivery payments relation without losing legacy data', () {
    expect(
      deliveryPaymentsRepair,
      contains("to_regclass('public.delivery_payments') is null"),
    );
    expect(
      deliveryPaymentsRepair,
      contains("to_regclass('public.delivery_payment') is not null"),
    );
    expect(
      deliveryPaymentsRepair,
      contains('rename to delivery_payments'),
    );
    expect(
      deliveryPaymentsRepair,
      contains('create table public.delivery_payments'),
    );
    expect(deliveryPaymentsRepair, isNot(contains('drop table')));
  });
}
