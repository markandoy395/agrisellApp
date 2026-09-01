import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/features/rider/deliveries/data/rider_map_discovery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';

void main() {
  test(
    'nearby farm repository maps a verified farm without an order',
    () async {
      late http.Request captured;
      final client = SupabaseClient(
        'https://example.supabase.co',
        'test-publishable-key',
        httpClient: MockClient((request) async {
          captured = request;
          return http.Response(
            jsonEncode([
              {
                'farm_id': 17,
                'farm_name': 'Independent Farm',
                'farm_location': 'Carmen pickup',
                'latitude': 8.4805,
                'longitude': 124.6505,
                'main_crops': ['Corn', 'Rice'],
                'distance_km': 0.08,
              },
            ]),
            200,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }),
        accessToken: () async => 'test-access-token',
      );
      addTearDown(client.dispose);

      final farms = await SupabaseRiderMapDiscoveryRepository(client)
          .fetchNearbyFarms(
            const RiderDeliverySearch(latitude: 8.48, longitude: 124.65),
          );

      expect(farms, hasLength(1));
      expect(farms.single.id, '17');
      expect(farms.single.name, 'Independent Farm');
      expect(farms.single.cropsLabel, 'Corn, Rice');
      expect(captured.url.path, endsWith('/rpc/current_rider_nearby_farms'));
      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body['p_radius_km'], 15);
      expect(body['p_limit'], 50);
    },
  );
}
