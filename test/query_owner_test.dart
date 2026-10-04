import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agresell_app/core/services/query_owner.dart';
import 'package:agresell_app/features/auth/data/buyer_shipping_address_repository.dart';
import 'package:agresell_app/features/rider/profile/data/supabase_rider_data_source.dart';
import 'package:agresell_app/features/rider/deliveries/data/supabase_delivery_data_source.dart';
import 'package:agresell_app/features/shared/safety/data/supabase_safety_incident_repository.dart';
import 'support/supabase_session_fixture.dart';

void main() {
  late SupabaseClient client;
  late List<http.Request> requests;
  late Object Function(http.Request) response;
  setUp(() {
    requests = [];
    response = (_) => [];
    client = SupabaseClient(
      'https://example.supabase.co',
      'test-key',
      httpClient: MockClient((request) async {
        requests.add(request);
        return http.Response(
          jsonEncode(response(request)),
          200,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      }),
    );
  });
  tearDown(() => client.dispose());

  test(
    'signed-out personal-data lookups fail before any HTTP request',
    () async {
      await expectLater(
        QueryOwner(client).userId(),
        throwsA(isA<AuthException>()),
      );
      await expectLater(
        BuyerShippingAddressRepository(client).load(),
        throwsA(isA<AuthException>()),
      );
      await expectLater(
        SupabaseSafetyIncidentRepository(client: client).getMyIncidents(),
        throwsA(isA<AuthException>()),
      );
      expect(requests, isEmpty);
    },
  );

  test(
    'buyer queries use server-derived numeric IDs, not login UUIDs',
    () async {
      await setTestSupabaseSession(client);
      response = (request) => request.url.path.endsWith('current_query_owner')
          ? {'auth_user_id': client.auth.currentUser!.id, 'buyer_user_id': 42}
          : {'shipping_address': 'My address', 'gps_lat': 8, 'gps_long': 124};
      final address = await BuyerShippingAddressRepository(client).load();
      expect(address!.address, 'My address');
      expect(requests.last.url.queryParameters['buyer_user_id'], 'eq.42');
    },
  );

  test('identity returned for another account is rejected', () async {
    await setTestSupabaseSession(client);
    response = (_) => {'auth_user_id': 'user-b', 'user_id': 99};
    await expectLater(
      QueryOwner(client).userId(),
      throwsA(isA<AuthException>()),
    );
    expect(requests.length, 1);
  });

  test(
    'rider ID tampering cannot issue a location/document mutation',
    () async {
      await setTestSupabaseSession(client);
      response = (_) => {
        'auth_user_id': client.auth.currentUser!.id,
        'rider_id': 'rider-a',
      };
      final source = SupabaseRiderDataSource(client: client);
      await expectLater(
        source.updateRider('rider-b', {'first_name': 'Hacked'}),
        throwsA(isA<AuthException>()),
      );
      await expectLater(
        source.getDocuments('rider-b'),
        throwsA(isA<AuthException>()),
      );
      expect(requests.every((request) => request.method == 'POST'), isTrue);
      expect(
        requests.every(
          (request) => request.url.path.endsWith('/rpc/current_query_owner'),
        ),
        isTrue,
      );
    },
  );

  test(
    'deleting documents includes both the document ID and current rider ID',
    () async {
      await setTestSupabaseSession(client);
      response = (request) =>
          request.url.path.endsWith('/rpc/current_query_owner')
          ? {'auth_user_id': client.auth.currentUser!.id, 'rider_id': 'rider-a'}
          : [];
      await SupabaseRiderDataSource(
        client: client,
      ).deleteDocument('document-b');
      expect(requests.last.method, 'DELETE');
      expect(requests.last.url.queryParameters['document_id'], 'eq.document-b');
      expect(requests.last.url.queryParameters['rider_id'], 'eq.rider-a');
    },
  );

  test(
    'delivery proof reads filter the proof owner without a delivery rider column',
    () async {
      await setTestSupabaseSession(client);
      response = (request) =>
          request.url.path.endsWith('/rpc/current_query_owner')
          ? {'auth_user_id': client.auth.currentUser!.id, 'rider_id': 'rider-a'}
          : [];
      final proofs = await SupabaseDeliveryDataSource(
        client,
      ).getDeliveryProofs('123');
      expect(proofs, isEmpty);
      final query = requests.last.url.queryParameters;
      expect(query['delivery_id'], 'eq.123');
      expect(query['rider_id'], 'eq.rider-a');
      expect(query['select'], isNot(contains('deliveries')));
    },
  );

  test('storage and notification IDs from another user are rejected', () async {
    await setTestSupabaseSession(client);
    final owner = QueryOwner(client);
    expect(() => owner.requireAuthId('user-b'), throwsA(isA<AuthException>()));
    await expectLater(
      owner.requireStoragePath('user-b/document.jpg'),
      throwsA(isA<AuthException>()),
    );
    expect(requests, isEmpty);
  });
}
