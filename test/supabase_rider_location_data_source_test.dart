import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/features/rider/deliveries/domain/rider_location.dart';
import 'package:agresell_app/features/rider/profile/data/supabase_rider_data_source.dart';

void main() {
  test('live Rider GPS is upserted into rider_locations', () async {
    http.Request? capturedRequest;
    final capturedAt = DateTime.utc(2026, 8, 10, 1, 2, 3);
    final httpClient = MockClient((request) async {
      capturedRequest = request;
      return http.Response(
        jsonEncode({
          'location_id': 'location-1',
          'rider_id': 'rider-1',
          'latitude': 8.4822,
          'longitude': 124.6472,
          'accuracy_meters': 7,
          'heading': 0,
          'speed_kph': 0,
          'location_updated_at': capturedAt.toIso8601String(),
        }),
        200,
        headers: {'content-type': 'application/json'},
        request: request,
      );
    });
    final client = SupabaseClient(
      'https://example.supabase.co',
      'test-publishable-key',
      httpClient: httpClient,
      accessToken: () async => 'test-access-token',
    );
    addTearDown(client.dispose);
    final source = SupabaseRiderDataSource(client: client);

    final saved = await source.upsertLocation(
      RiderLocation(
        riderId: 'rider-1',
        latitude: 8.4822,
        longitude: 124.6472,
        accuracyMeters: 7,
        speedMetersPerSecond: -1,
        headingDegrees: -1,
        timestamp: capturedAt,
      ),
    );

    expect(capturedRequest?.url.path, endsWith('/rest/v1/rider_locations'));
    expect(capturedRequest?.url.queryParameters['on_conflict'], 'rider_id');
    expect(jsonDecode(capturedRequest!.body), {
      'rider_id': 'rider-1',
      'latitude': 8.4822,
      'longitude': 124.6472,
      'accuracy_meters': 7.0,
      'heading': 0.0,
      'speed_kph': 0.0,
      'location_updated_at': capturedAt.toIso8601String(),
    });
    expect(saved.locationId, 'location-1');
    expect(saved.riderId, 'rider-1');
  });
}
