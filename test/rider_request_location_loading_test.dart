import 'dart:convert';

import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/data/supabase_delivery_data_source.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_bundle.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_location.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'support/rider_test_models.dart';

void main() {
  test('diagnostics include only short codes, never server payloads', () {
    final error = DeliveryDataException(
      DeliveryDataFailureType.database,
      'private response',
      const PostgrestException(
        message: 'private response',
        code: 'bad code with payload',
      ),
    );
    expect(error.diagnosticCode, 'database');
  });

  test('RPC bundle preserves addresses with missing coordinates', () {
    final bundle = DeliveryBundle.fromJson(_delivery());
    expect(bundle.pickup!.address, 'Farm address');
    expect(bundle.pickup!.hasCoordinates, isTrue);
    expect(bundle.pickup!.latitude, 8.48);
    expect(bundle.dropoff!.hasCoordinates, isFalse);
    expect(bundle.dropoff!.longitude, isNull);
    expect(bundle.dropoff!.address, 'Buyer address');
  });

  test('normalized locations still require coordinates by default', () {
    expect(
      () => DeliveryLocation.fromJson(_location('pickup', 'Farm address')),
      throwsFormatException,
    );
  });

  test('malformed supplied coordinates are rejected in an RPC bundle', () {
    final row = _delivery();
    row['locations'] = [
      {..._location('pickup', 'Farm'), 'latitude': 'not-a-number'},
    ];
    expect(() => DeliveryBundle.fromJson(row), throwsFormatException);
  });

  test(
    'one missing dropoff pin does not fail the full list or Retry',
    () async {
      var calls = 0;
      final controller = _controller((request) async {
        calls++;
        expect(
          request.url.path,
          endsWith('/rpc/current_rider_nearby_deliveries'),
        );
        final complete = _delivery(id: 2);
        complete['locations'] = [
          {
            ..._location('pickup', 'Pinned farm'),
            'latitude': 8.48,
            'longitude': 124.65,
          },
          {
            ..._location('dropoff', 'Pinned buyer'),
            'latitude': 8.49,
            'longitude': 124.66,
          },
        ];
        return http.Response(
          jsonEncode([_delivery(), complete]),
          200,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      });
      await controller.load(riderId: 'rider-a');
      expect(controller.loadState, RiderRequestLoadState.ready);
      expect(controller.errorMessage, isNull);
      expect(
        controller.requests.map((item) => item.id),
        containsAll(['1', '2']),
      );
      expect(
        controller.requests
            .firstWhere((item) => item.id == '1')
            .deliveryLocation
            .hasCoordinates,
        isFalse,
      );
      await controller.refreshRequests();
      expect(calls, 2);
      expect(controller.loadState, RiderRequestLoadState.ready);
      expect(controller.requests, hasLength(2));
    },
  );

  test('Retry recovers after a temporary service failure', () async {
    var calls = 0;
    final controller = _controller((request) async {
      if (++calls == 1) {
        return http.Response(
          jsonEncode({'code': 'XX000', 'message': 'private details'}),
          500,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      }
      return http.Response(
        jsonEncode([_delivery()]),
        200,
        headers: {'content-type': 'application/json'},
        request: request,
      );
    });
    await controller.load(riderId: 'rider-a');
    expect(controller.loadState, RiderRequestLoadState.error);
    expect(controller.errorMessage, isNot(contains('private details')));
    await controller.refreshRequests();
    expect(controller.loadState, RiderRequestLoadState.ready);
    expect(controller.errorMessage, isNull);
  });

  test(
    'authorization denial remains an error without fallback reads',
    () async {
      var calls = 0;
      final controller = _controller((request) async {
        calls++;
        return http.Response(
          jsonEncode({'code': '42501', 'message': 'private details'}),
          403,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      });
      await controller.load(riderId: 'rider-a');
      expect(controller.loadState, RiderRequestLoadState.error);
      expect(controller.requests, isEmpty);
      expect(controller.errorMessage, contains('cannot access'));
      expect(controller.errorMessage, isNot(contains('private details')));
      expect(calls, 1);
    },
  );

  test(
    'missing or expired authentication requires sign-in without fallback',
    () async {
      var calls = 0;
      final controller = _controller((request) async {
        calls++;
        return http.Response(
          jsonEncode({'code': 'PGRST301', 'message': 'private details'}),
          401,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      });
      await controller.load(riderId: 'rider-a');
      expect(controller.loadState, RiderRequestLoadState.error);
      expect(controller.requests, isEmpty);
      expect(
        controller.errorMessage,
        'Please sign in again to load delivery requests.',
      );
      expect(calls, 1);
    },
  );
}

RiderDeliveryController _controller(MockClientHandler handler) {
  final client = SupabaseClient(
    'https://example.supabase.co',
    'test-key',
    httpClient: MockClient(handler),
    accessToken: () async => 'test-token',
  );
  addTearDown(client.dispose);
  final controller =
      RiderDeliveryController(
          repository: _Repository(SupabaseDeliveryDataSource(client)),
        )
        ..updateProfile(verifiedRiderProfile())
        ..setOnline(true)
        ..updateRequestEnvironment(
          state: RiderRequestAccessState.eligible,
          location: const RiderDeliverySearch(
            latitude: 8.48,
            longitude: 124.65,
          ),
          accuracyMeters: 5,
        );
  addTearDown(controller.dispose);
  return controller;
}

class _Repository extends SupabaseRiderDeliveryRepository {
  _Repository(super.dataSource);

  @override
  Stream<void> watchRequestChanges({required String riderId}) =>
      const Stream.empty();
}

Map<String, Object?> _delivery({int id = 1}) => {
  'delivery_id': id,
  'order_id': id,
  'delivery_status': 'available',
  'created_at': '2026-10-13T01:00:00Z',
  'pickup_location': 'Farm address',
  'dropoff_location': 'Buyer address',
  'assigned_to_current_rider': false,
  'assignment_request_id': 'selected-$id',
  'assignment_request_status': 'pending',
  'assignment_request_expires_at': '2030-01-01T00:00:00Z',
  'locations': [
    {
      ..._location('pickup', 'Farm address'),
      'latitude': 8.48,
      'longitude': 124.65,
    },
    _location('dropoff', 'Buyer address'),
  ],
};

Map<String, Object?> _location(String type, String address) => {
  'location_type': type,
  'address': address,
  'latitude': null,
  'longitude': null,
};
