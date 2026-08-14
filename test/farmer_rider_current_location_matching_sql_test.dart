import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String sql;
  late String repairSql;

  setUpAll(() {
    sql = File(
      'supabase/migrations/'
      '20260808130000_rank_farmer_riders_by_current_location.sql',
    ).readAsStringSync();
    repairSql = File(
      'supabase/migrations/'
      '20260808143000_harden_farmer_rider_live_location_rpc.sql',
    ).readAsStringSync();
  });

  test('separates registered service eligibility from current GPS ranking', () {
    expect(sql, contains('public.rider_locations as current_location'));
    expect(sql, contains('private.rider_current_location_is_fresh'));
    expect(sql, contains('private.rider_distance_from_current_location_km'));
    expect(sql, contains('private.rider_current_location_updated_at'));
    expect(sql, isNot(contains('left join public.rider_locations')));
    expect(
      sql,
      contains(
        "current_location.location_updated_at >= now() - interval '2 minutes'",
      ),
    );
    expect(sql, contains('target.pickup_lat::double precision'));
    expect(sql, contains('target.pickup_long::double precision'));
    expect(sql, isNot(contains('rider.gps_lat::double precision')));
    expect(sql, isNot(contains('rider.gps_long::double precision')));
  });

  test('repair migration removes old direct rider location joins', () {
    expect(repairSql, contains('pg_get_functiondef'));
    expect(repairSql, contains('private.rider_current_location_updated_at'));
    expect(
      repairSql,
      contains('Farmer Rider directory still joins public.rider_locations'),
    );
  });

  test('orders requestable riders by current distance before admin area', () {
    expect(sql, contains('candidate.is_requestable desc'));
    expect(sql, contains('candidate.distance_km asc nulls last'));
    expect(sql, contains('candidate.active_delivery_count asc'));
    expect(sql, contains('candidate.same_municipality desc'));
    expect(sql, contains('candidate.same_barangay desc'));
  });

  test(
    'farmer request is revalidated against online fresh-location eligibility',
    () {
      expect(sql, contains("rider.availability_status = 'online'"));
      expect(
        sql,
        contains('private.rider_current_location_is_fresh(rider.rider_id)'),
      );
      expect(sql, contains('private.rider_is_visible_for_delivery'));
      expect(sql, contains('public.request_current_farmer_rider'));
      expect(sql, contains('private.rider_is_eligible_for_delivery'));
      expect(
        sql,
        contains(
          'This rider is no longer available. Please choose another rider.',
        ),
      );
    },
  );
}
