import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String migration;
  late String snapshotCompatibilityMigration;

  setUpAll(() {
    migration = File(
      'supabase/migrations/'
      '20260903100000_fix_farmer_order_acceptance_sync.sql',
    ).readAsStringSync();
    snapshotCompatibilityMigration = File(
      'supabase/migrations/'
      '20260903103000_ignore_unrelated_farmer_order_snapshot_statuses.sql',
    ).readAsStringSync();
  });

  test('farmer sync ignores unchanged normalized order statuses', () {
    expect(migration, contains("when 'pending' then 'toShip'"));
    expect(migration, contains("when 'placed' then 'toShip'"));
    expect(migration, contains("when 'completed' then 'delivered'"));
    expect(migration, contains('end <> requested_status'));
    expect(migration, contains('continue;'));
  });

  test('farmer can accept only awaiting orders', () {
    expect(migration, contains("requested_status = 'preparing'"));
    expect(
      migration,
      contains("set order_status = 'preparing', updated_at = now()"),
    );
    expect(migration, contains("'pending', 'placed', 'to_ship', 'toship'"));
    expect(migration, contains('Only an awaiting order can be accepted'));
  });

  test('farmer sync retains the ready-for-pickup operation', () {
    expect(migration, contains("requested_status = 'readyForPickup'"));
    expect(migration, contains('private.mark_farmer_order_ready'));
    expect(
      migration,
      isNot(contains('Only the rider can confirm pickup or delivery')),
    );
  });

  test('unrelated snapshot statuses cannot roll back an acceptance', () {
    expect(snapshotCompatibilityMigration, contains('pg_get_functiondef'));
    expect(
      snapshotCompatibilityMigration,
      contains('A non-actionable historical order must not roll back'),
    );
    expect(snapshotCompatibilityMigration, contains("'continue;'"));
    expect(
      snapshotCompatibilityMigration,
      contains('execute updated_definition'),
    );
  });
}
