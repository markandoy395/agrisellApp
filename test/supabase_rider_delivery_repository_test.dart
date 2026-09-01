import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/data/supabase_delivery_data_source.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';

void main() {
  test('Supabase Rider repository maps the final ERD delivery RPC', () async {
    final requests = <Uri>[];
    final httpClient = MockClient((request) async {
      requests.add(request.url);
      return http.Response(
        jsonEncode([_availableDelivery]),
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
    final dataSource = SupabaseDeliveryDataSource(client);
    final repository = SupabaseRiderDeliveryRepository(dataSource);

    final values = await repository.fetchRequests(riderId: 'auth-rider-1');

    expect(dataSource.client, same(client));
    expect(repository, isA<RiderDeliveryRepository>());
    expect(values, hasLength(1));
    expect(values.single.id, '7');
    expect(values.single.pickupLocation.address, 'Carmen Market');
    expect(values.single.deliveryLocation.address, 'Uptown Buyer');
    expect(values.single.deliveryFee, 0);
    expect(values.single.isCashOnDelivery, isTrue);
    expect(values.single.cashOnDelivery?.amountToCollect, 450);
    expect(values.single.reservedRiderId, 'auth-rider-1');
    expect(
      values.single.reservedUntil,
      DateTime.parse('2026-07-16T02:00:00Z').toLocal(),
    );
    expect(
      requests.any((uri) => uri.path.endsWith('/rpc/current_rider_deliveries')),
      isTrue,
    );
  });

  test('map discovery sends a bounded GPS query to Supabase', () async {
    late http.Request captured;
    final httpClient = MockClient((request) async {
      captured = request;
      return http.Response(
        jsonEncode([_availableDelivery]),
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

    final values = await SupabaseDeliveryDataSource(client)
        .getNearbyDeliveries(
          const RiderDeliverySearch(
            latitude: 8.48,
            longitude: 124.65,
            radiusKm: 12,
          ),
        );

    expect(values, hasLength(1));
    expect(
      captured.url.path,
      endsWith('/rpc/current_rider_nearby_deliveries'),
    );
    final body = jsonDecode(captured.body) as Map<String, dynamic>;
    expect(body['p_latitude'], 8.48);
    expect(body['p_longitude'], 124.65);
    expect(body['p_radius_km'], 12);
    expect(body['p_limit'], 50);
  });
}

const _availableDelivery = <String, Object?>{
  'delivery_id': 7,
  'order_id': 9,
  'delivery_status': 'available',
  'estimated_delivery_time': '2026-07-16T04:00:00Z',
  'actual_delivery_time': null,
  'created_at': '2026-07-16T01:00:00Z',
  'vehicle_types': 'motorcycle',
  'cold_chain_available': false,
  'pickup_location': 'Carmen Market',
  'dropoff_location': 'Uptown Buyer',
  'distance_km': 4.2,
  'payment_method': 'cash_on_delivery',
  'payment_status': 'pending_collection',
  'amount_to_collect': 450,
  'assigned_to_current_rider': false,
  'assignment_request_id': 'request-1',
  'assignment_request_status': 'pending',
  'assignment_request_expires_at': '2026-07-16T02:00:00Z',
};
