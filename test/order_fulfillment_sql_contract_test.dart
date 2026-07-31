import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String checkoutSql;
  late String cancellationSql;
  late String readySql;
  late String deliverySql;
  late String wrappersSql;
  late String codSql;

  setUpAll(() {
    checkoutSql = _migration('20260729100002_create_seller_scoped_orders.sql');
    cancellationSql = _migration('20260729100001_order_stock_reservation.sql');
    readySql = _migration('20260729100004_create_delivery_on_ready.sql');
    deliverySql = _migration('20260729100007_secure_delivery_transitions.sql');
    wrappersSql = _migration('20260729100008_expose_secure_delivery_rpcs.sql');
    codSql = _migration('20260729130000_complete_cod_delivery.sql');
  });

  test('checkout locks inventory and validates every sale constraint', () {
    expect(checkoutSql, contains('for update;'));
    expect(checkoutSql, contains('commodity_status'));
    expect(
      checkoutSql,
      contains("availability_status = 'not_accepting_orders'"),
    );
    expect(checkoutSql, contains('minimum_order_quantity'));
    expect(checkoutSql, contains('item_group.quantity >'));
    expect(
      checkoutSql,
      contains('available_quantity = available_quantity - item_group.quantity'),
    );
  });

  test('checkout produces deterministic seller-scoped order IDs', () {
    expect(
      checkoutSql,
      contains("checkout_id || '-F' || commodity_record.farm_id"),
    );
    expect(checkoutSql, contains('seller_farm_id'));
    expect(checkoutSql, contains('stock_reserved_at'));
  });

  test('cancellation releases reserved stock exactly once', () {
    expect(cancellationSql, contains('stock_reserved_at is not null'));
    expect(cancellationSql, contains('stock_released_at is null'));
    expect(
      cancellationSql,
      contains('available_quantity = available_quantity + released.quantity'),
    );
    expect(cancellationSql, contains('rider_delivery_assignments'));
  });

  test('ready for pickup creates a location-backed delivery request', () {
    expect(readySql, contains('insert into public.deliveries'));
    expect(readySql, contains('order_delivery_fulfillments'));
    expect(readySql, contains('pickup_lat'));
    expect(readySql, contains('dropoff_lat'));
    expect(readySql, contains('required_vehicle_type'));
  });

  test('assigned rider pickup and completion control order status', () {
    expect(deliverySql, contains('rider_delivery_assignments'));
    expect(deliverySql, contains("p_new_status = 'picked_up'"));
    expect(deliverySql, contains("then 'shipping' else 'delivered'"));
    expect(deliverySql, contains('delivery_status_events'));
  });

  test('Flutter delivery RPCs are secure wrappers', () {
    expect(wrappersSql, contains('security invoker'));
    expect(wrappersSql, contains('private.current_rider_deliveries'));
    expect(wrappersSql, contains('private.accept_delivery'));
    expect(wrappersSql, contains('private.update_delivery_status'));
    expect(wrappersSql, contains('from public, anon'));
  });

  test('COD completion verifies cash and settles payment atomically', () {
    expect(codSql, contains('private.delivery_cash_collections'));
    expect(codSql, contains('abs(p_cash_amount -'));
    expect(codSql, contains("set payment_status = 'verified'"));
    expect(codSql, contains("set payment_status = 'paid'"));
    expect(codSql, contains('private.update_delivery_status'));
    expect(codSql, contains('security invoker'));
  });
}

String _migration(String name) =>
    File('supabase/migrations/$name').readAsStringSync();
