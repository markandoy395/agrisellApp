import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String sql;

  setUpAll(() {
    sql = File(
      'supabase/migrations/'
      '20260809100000_include_buyer_destination_in_rider_matching.sql',
    ).readAsStringSync();
  });

  test('reuses current order delivery coordinates for buyer destination', () {
    expect(sql, contains('seller_order_current_delivery_location'));
    expect(sql, contains('order_record.delivery_address'));
    expect(sql, contains('order_record.delivery_latitude'));
    expect(sql, contains('order_record.delivery_longitude'));
    expect(sql, contains('refresh_delivery_destination_from_current_order'));
    expect(
      sql,
      contains(
        "The buyer''s delivery location needs to be confirmed before selecting a rider.",
      ),
    );
  });

  test(
    'rider eligibility requires pickup and buyer destination service area',
    () {
      expect(sql, contains('rider_registered_service_area_contains'));
      expect(sql, contains('fulfillment.pickup_lat::double precision'));
      expect(sql, contains('fulfillment.pickup_long::double precision'));
      expect(sql, contains('destination.latitude::double precision'));
      expect(sql, contains('destination.longitude::double precision'));
      expect(sql, contains('private.rider_current_location_is_fresh'));
      expect(sql, contains('private.rider_is_visible_for_delivery'));
      expect(sql, contains('<= 15::double precision'));
      expect(sql, isNot(contains('rider.service_radius_km')));
    },
  );

  test('farmer rider list exposes full route details and filters riders', () {
    expect(sql, contains("'destination_latitude', target.dropoff_lat"));
    expect(sql, contains("'destination_longitude', target.dropoff_long"));
    expect(sql, contains("'route_distance_km'"));
    expect(sql, contains("'destination_supported', true"));
    expect(sql, contains("'delivery_distance_km'"));
    expect(
      sql,
      contains(
        'and private.rider_registered_service_area_contains(\n'
        '            target.dropoff_lat::double precision,',
      ),
    );
  });

  test('request submission refreshes and revalidates destination', () {
    expect(sql, contains('public.request_current_farmer_rider'));
    expect(
      sql,
      contains(
        'perform private.refresh_delivery_destination_from_current_order(target.delivery_id);',
      ),
    );
    expect(sql, contains('private.rider_is_eligible_for_delivery'));
  });
}
