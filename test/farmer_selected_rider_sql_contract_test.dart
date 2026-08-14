import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String sql;

  setUpAll(() {
    sql = File(
      'supabase/migrations/20260802120000_add_farmer_selected_riders.sql',
    ).readAsStringSync();
  });

  test('persists one active request with participant-only RLS', () {
    expect(sql, contains('create table public.rider_assignment_requests'));
    expect(sql, contains('rider_assignment_requests_one_pending_delivery_idx'));
    expect(sql, contains('where status = \'pending\''));
    expect(sql, contains('farmer_user_id = private.current_farmer_user_id()'));
    expect(sql, contains('rider_id = private.current_rider_id()'));
    expect(sql, contains('revoke all on public.rider_assignment_requests'));
  });

  test('eligibility and ordering are server-authoritative', () {
    expect(sql, contains("rider.employment_status = 'active'"));
    expect(sql, contains("rider.availability_status = 'online'"));
    expect(
      sql,
      contains(
        "lower(coalesce(rider.location_label, '')),\n"
        '          lower(btrim(farm.city_municipality))',
      ),
    );
    expect(sql, contains('array_to_string(company.service_areas'));
    expect(sql, contains('lower(fulfillment.required_vehicle_type)'));
    expect(
      sql,
      contains(
        'not exists (\n        select 1\n        from private.rider_delivery_assignments',
      ),
    );
    expect(
      sql,
      contains(
        'order by candidate.same_barangay desc,\n'
        '        candidate.distance_km asc nulls last,',
      ),
    );
  });

  test('acceptance locks and assigns atomically to selected rider only', () {
    expect(sql, contains('where delivery_id = p_delivery_id for update'));
    expect(sql, contains("and status in ('pending', 'accepted')"));
    expect(
      sql,
      contains(
        "raise exception 'This delivery was not requested for this Rider'",
      ),
    );
    expect(sql, contains('insert into private.rider_delivery_assignments'));
    expect(sql, contains("set status = 'accepted', responded_at = now()"));
    expect(sql, contains("set availability_status = 'busy'"));
    expect(sql, contains('where rider_id = current_rider for update'));
  });

  test('uses the deployed final-ERD rider identity and location fields', () {
    expect(sql, contains('join private.auth_identities as identity'));
    expect(sql, contains('identity.auth_user_id'));
    expect(sql, isNot(contains('rider.auth_id')));
    expect(sql, isNot(contains('rider.verification_status')));
    expect(sql, isNot(contains('rider.delivery_status')));
    expect(sql, isNot(contains('public.rider_vehicles')));
    expect(sql, isNot(contains('public.rider_locations')));
    expect(sql, isNot(contains('public.delivery_payments')));
  });

  test(
    'decline, cancellation, expiration, realtime and notifications exist',
    () {
      expect(sql, contains('public.decline_delivery_request'));
      expect(sql, contains('public.cancel_current_farmer_rider_request'));
      expect(sql, contains('private.process_rider_assignment_expirations'));
      expect(sql, contains('agrisell-rider-assignment-expiration'));
      expect(sql, contains('rider_assignment_requests_notify_status'));
      expect(sql, contains('alter publication supabase_realtime'));
      expect(sql, contains("'delivery_request', 'orders', 'deliveries'"));
    },
  );
}
