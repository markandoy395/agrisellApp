import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agresell_app/features/auth/data/buyer_shipping_address_repository.dart';
import 'package:agresell_app/features/auth/domain/buyer_shipping_address.dart';
import 'package:agresell_app/features/rider/profile/data/supabase_rider_data_source.dart';
import 'package:agresell_app/features/rider/profile/data/rider_repository_impl.dart';
import 'package:agresell_app/features/rider/profile/presentation/utils/rider_profile_save_coordinator.dart';

import 'support/rider_test_models.dart';
import 'support/supabase_session_fixture.dart';

const _authId = 'aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa';
const _headers = {'content-type': 'application/json'};

void main() {
  test(
    'Buyer address edits bind the full literal address and coordinates',
    () async {
      http.Request? captured;
      final client = _client((request) async {
        captured = request;
        return _response(request, "12 O'Neil %_* Street; --, Philippines");
      });
      addTearDown(client.dispose);
      await setTestSupabaseSession(client);
      final address = const BuyerShippingAddress(
        address: "12 O'Neil %_* Street; --, Philippines",
        latitude: 8.4822,
        longitude: 124.6472,
      );
      final saved = await BuyerShippingAddressRepository(client).save(address);
      expect(saved.address, address.address);
      expect(
        captured!.url.path,
        '/rest/v1/rpc/set_current_buyer_shipping_address_location',
      );
      expect(captured!.method, 'POST');
      expect(captured!.url.query, isEmpty);
      expect(jsonDecode(captured!.body), {
        'address_value': address.address,
        'latitude_value': 8.4822,
        'longitude_value': 124.6472,
      });
      expect(captured!.body, isNot(contains('buyer_user_id')));
    },
  );

  test(
    'Rider edits bind values and scope the update to resolved rider ID',
    () async {
      http.Request? update;
      final client = _client((request) async {
        if (request.url.path.endsWith('/rpc/current_query_owner')) {
          return _response(request, {'auth_user_id': _authId, 'rider_id': 7});
        }
        update = request;
        return _response(request, {'rider_id': 7, ...jsonDecode(request.body)});
      });
      addTearDown(client.dispose);
      await setTestSupabaseSession(client);
      final saved = await SupabaseRiderDataSource(client: client)
          .updateRider('7', {
            'first_name': "Ana O'Neil",
            'last_name': 'De la Cruz',
            'address_line': "12 %_* Street'; --",
            'postal_code': '9000',
            'gps_lat': 8.48,
            'gps_long': 124.65,
          });
      expect(update!.method, 'PATCH');
      expect(update!.url.queryParameters['rider_id'], 'eq.7');
      expect(jsonDecode(update!.body)['address_line'], "12 %_* Street'; --");
      expect(saved.firstName, "Ana O'Neil");
      expect(saved.lastName, 'De la Cruz');
      expect(saved.addressLine, "12 %_* Street'; --");
      expect(saved.postalCode, '9000');
    },
  );

  for (final signedIn in [false, true]) {
    test(
      'Rider ${signedIn ? 'cross-account' : 'signed-out'} edit issues no update',
      () async {
        var updates = 0;
        final client = _client((request) async {
          if (request.method == 'PATCH') updates++;
          return _response(request, {'auth_user_id': _authId, 'rider_id': 7});
        });
        addTearDown(client.dispose);
        if (signedIn) await setTestSupabaseSession(client);
        await expectLater(
          SupabaseRiderDataSource(
            client: client,
          ).updateRider('8', {'first_name': 'Other'}),
          throwsA(isA<AuthException>()),
        );
        expect(updates, 0);
      },
    );
  }

  test(
    'Vehicle details and capacity persist in one RPC and survive reload',
    () async {
      final persisted = <String, Object?>{
        'rider_id': '7',
        'vehicle_type': 'motorcycle',
        'vehicle_plate_number': 'OLD 123',
        'capacity_kg': 10,
      };
      var mutations = 0;
      final client = _client((request) async {
        if (request.url.path.endsWith('/rpc/current_query_owner'))
          return _response(request, {'auth_user_id': _authId, 'rider_id': '7'});
        if (request.url.path.endsWith('/rpc/update_current_rider_vehicle')) {
          mutations++;
          final values =
              jsonDecode(request.body)['vehicle_payload']
                  as Map<String, dynamic>;
          persisted.addAll(values);
          persisted['vehicle_plate_number'] = values['plate_number'];
          return _response(request, persisted);
        }
        expect(request.method, 'GET');
        return _response(request, persisted);
      });
      addTearDown(client.dispose);
      await setTestSupabaseSession(client);
      final source = SupabaseRiderDataSource(client: client);
      final repository = RiderRepositoryImpl(remote: source);
      final loaded = (await source.getVehicles('7')).single;
      final saved = await repository.updateVehicle(
        loaded.copyWith(
          vehicleBrand: 'Brand A',
          vehicleModel: 'Model B',
          vehicleColor: 'Blue',
          registrationNumber: 'REG 789',
          plateNumber: 'NEW 456',
          capacityKg: 20,
        ),
      );
      expect(mutations, 1);
      expect(saved.vehicleModel, 'Model B');
      final reloaded = (await source.getVehicles('7')).single;
      expect(reloaded.vehicleBrand, 'Brand A');
      expect(reloaded.vehicleModel, 'Model B');
      expect(reloaded.vehicleColor, 'Blue');
      expect(reloaded.registrationNumber, 'REG 789');
      expect(reloaded.plateNumber, 'NEW 456');
      expect(reloaded.capacityKg, 20);
    },
  );
  test('Compound names retain explicit first and last name boundaries', () {
    final original = verifiedRiderProfile();
    final edited = RiderProfileSaveCoordinator.buildUpdatedProfile(
      original: original,
      firstName: 'Ana Maria',
      lastName: 'De la Cruz',
      contact: original.contactNumber,
      license: original.licenseNumber,
      plate: original.vehiclePlateNumber,
      street: '12 Market Street',
      province: 'Misamis Oriental',
      city: 'Cagayan de Oro',
      barangay: 'Lapasan',
      postal: '9000',
      latitude: 8.48,
      longitude: 124.65,
    );
    expect(edited.firstName, 'Ana Maria');
    expect(edited.lastName, 'De la Cruz');
    final unrelatedEdit = edited.copyWith(contactNumber: '09171234567');
    expect(unrelatedEdit.firstName, 'Ana Maria');
    expect(unrelatedEdit.lastName, 'De la Cruz');
  });
}

SupabaseClient _client(MockClientHandler handler) => SupabaseClient(
  'https://example.supabase.co',
  'test-key',
  httpClient: MockClient(handler),
);

http.Response _response(http.Request request, Object? body) =>
    http.Response(jsonEncode(body), 200, headers: _headers, request: request);
