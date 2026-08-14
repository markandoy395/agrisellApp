import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final migration = File(
    'supabase/migrations/'
    '20260810140000_controlled_rider_multi_delivery_batching.sql',
  );

  test('multi-delivery configuration remains opt-in and manager controlled', () {
    final sql = migration.readAsStringSync();

    expect(sql, contains('maximum_active_deliveries integer not null default 1'));
    expect(sql, contains("('motorcycle', 3, 1)"));
    expect(sql, contains("('tricycle', 5, 1)"));
    expect(sql, contains("('car', 5, 1)"));
    expect(sql, contains("('van', 10, 1)"));
    expect(sql, contains("('truck', 20, 1)"));
    expect(sql, contains('configure_rider_delivery_limit'));
    expect(sql, contains('can_manage_rider_delivery_limit'));
    expect(
      sql,
      contains('revoke update (maximum_active_deliveries) on public.riders'),
    );
  });

  test('acceptance serializes by Rider and validates active batches', () {
    final sql = migration.readAsStringSync();

    expect(sql, contains('where rider_id = p_rider_id for update'));
    expect(sql, contains('active_delivery_limit_reached'));
    expect(sql, isNot(contains("'completed', 'cancelled', 'failed'")));
    expect(sql, contains("'accepted', 'going_to_pickup'"));
    expect(sql, contains('capacity_conflict'));
    expect(sql, contains('vehicle_type_conflict'));
    expect(sql, contains('deadline_conflict'));
    expect(sql, contains('route_incompatible'));
    expect(sql, contains('product_handling_conflict'));
    expect(sql, contains('cod_responsibility_unavailable'));
    expect(sql, contains('validate_delivery_batch_acceptance'));
    expect(sql, contains('return private.accept_delivery'));
  });
}
