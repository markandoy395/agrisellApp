import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String sql;
  late String lifecycleSource;

  setUpAll(() {
    sql = File(
      'supabase/migrations/'
      '20260809130000_expire_stale_rider_availability.sql',
    ).readAsStringSync();
    lifecycleSource =
        File(
          'lib/features/rider/dashboard/presentation/screens/'
          'rider_home_lifecycle.dart',
        ).readAsStringSync() +
        File(
          'lib/features/rider/dashboard/presentation/screens/'
          'rider_home_location_lifecycle.dart',
        ).readAsStringSync();
  });

  test('keeps a Rider requestable for five minutes after the heartbeat', () {
    expect(
      sql,
      contains(
        "current_location.location_updated_at >= now() - interval '5 minutes'",
      ),
    );
    expect(sql, contains('private.rider_current_location_is_fresh'));
  });

  test('automatically expires only idle online Riders', () {
    expect(sql, contains("set availability_status = 'offline'"));
    expect(sql, contains("rider.availability_status = 'online'"));
    expect(sql, contains('private.rider_delivery_assignments'));
    expect(
      sql,
      contains(
        "delivery.delivery_status not in (\n"
        "          'completed', 'delivered', 'cancelled', 'failed', 'returned'",
      ),
    );
  });

  test('runs stale Rider expiration every minute on the server', () {
    expect(sql, contains('private.expire_stale_rider_availability()'));
    expect(sql, contains("'agrisell-stale-rider-availability'"));
    expect(sql, contains("'* * * * *'"));
  });

  test('tracks location only for map or active live sharing', () {
    expect(lifecycleSource, contains('_isAppInForeground &&'));
    expect(
      lifecycleSource,
      isNot(
        contains('_deliveryController.status.availability.canReceiveRequests'),
      ),
    );
    expect(lifecycleSource, contains('RiderHomeScreen.mapNavIndex'));
    expect(lifecycleSource, contains('_isAppInForeground = false'));
  });
}
