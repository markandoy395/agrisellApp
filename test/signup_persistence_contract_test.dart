import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agresell_app/features/auth/data/supabase_registration_handler.dart';
import 'package:agresell_app/features/auth/data/supabase_account_loader.dart';
import 'package:agresell_app/features/auth/data/auth_registration_exception.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/auth/presentation/controllers/sign_up_form_controllers.dart';
import 'package:agresell_app/features/farmer/registration/presentation/controllers/farmer_signup_controllers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Buyer form sends every profile field as literal RPC data', () async {
    final form = SignUpFormControllers();
    addTearDown(form.dispose);
    form.firstName.text = " Ana O'Neil ";
    form.lastName.text = ' Reyes ';
    form.extensionName.text = ' Jr. ';
    form.contactNumber.text = '09171234567';
    form.dateOfBirth.text = '1995-04-12';
    form.gender.text = 'Female';
    form.shippingAddress.text = " 12 %_* Street'; -- ";
    form.shippingProvince.text = ' Misamis Oriental ';
    form.shippingCity.text = ' Cagayan de Oro ';
    form.shippingBarangay.text = ' Lapasan ';
    form.shippingPostalCode.text = ' 9000 ';
    form.email.text = ' BUYER@EXAMPLE.INVALID ';
    form.password.text = 'Private123!';
    http.Request? submitted;
    final client = SupabaseClient(
      'https://example.supabase.co',
      'test-key',
      httpClient: MockClient((request) async {
        submitted = request;
        return http.Response(
          'null',
          200,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      }),
    );
    addTearDown(client.dispose);
    await _session(client, verified: true);
    final loader = _BuyerLoader(client);
    await SupabaseRegistrationHandler(
      client,
      accountLoader: loader,
    ).completeVerifiedBuyerRegistration(
      form.toAccountData(acceptedPolicy: true),
    );
    expect(
      submitted!.url.path,
      '/rest/v1/rpc/complete_current_buyer_registration',
    );
    expect(submitted!.method, 'POST');
    expect(submitted!.url.query, isEmpty);
    expect(jsonDecode(submitted!.body), {
      'buyer_payload': {
        'first_name': "Ana O'Neil",
        'last_name': 'Reyes',
        'extension_name': 'Jr.',
        'phone_number': '+639171234567',
        'date_of_birth': '1995-04-12',
        'gender': 'Female',
        'shipping_address':
            "12 %_* Street'; --, Barangay Lapasan, Cagayan de Oro, Misamis Oriental, 9000, Philippines",
        'accepted_policy': true,
      },
    });
    expect(loader.loads, 1);
    expect(submitted!.body, isNot(contains('Private123!')));
  });

  for (final verified in [false, true]) {
    test(
      'Buyer rejects ${verified ? 'wrong email' : 'unverified email'}',
      () async {
        var writes = 0;
        final client = SupabaseClient(
          'https://example.supabase.co',
          'test-key',
          httpClient: MockClient((_) async {
            writes++;
            return http.Response('null', 200);
          }),
        );
        addTearDown(client.dispose);
        await _session(client, verified: verified);
        await expectLater(
          SupabaseRegistrationHandler(client).completeVerifiedBuyerRegistration(
            SignUpAccountData(
              firstName: 'Ana',
              lastName: 'Reyes',
              email: verified
                  ? 'someone-else@example.invalid'
                  : 'buyer@example.invalid',
              password: '',
            ),
          ),
          throwsA(isA<AuthRegistrationException>()),
        );
        expect(writes, 0);
      },
    );
  }

  test(
    'Farmer form retains every personal, farm, image and location input',
    () {
      final form = FarmerSignupControllers();
      addTearDown(form.dispose);
      form.email.text = 'FARMER@EXAMPLE.INVALID';
      form.password.text = 'Private123!';
      final inputs = {
        form.firstName: 'Ana',
        form.middleName: 'Maria',
        form.lastName: 'Reyes',
        form.suffix: 'Jr.',
        form.phone: '09171234567',
        form.dateOfBirth: '1995-04-12',
        form.gender: 'Female',
        form.address: "12 O'Neil %_* Street",
        form.barangay: 'Lapasan',
        form.city: 'Cagayan de Oro',
        form.province: 'Misamis Oriental',
        form.postalCode: '9000',
        form.farmName: "Ana's Farm",
        form.farmAddress: 'Farm Road',
        form.farmBarangay: 'Canitoan',
        form.farmCity: 'Cagayan de Oro',
        form.farmProvince: 'Misamis Oriental',
        form.latitude: '8.48',
        form.longitude: '124.65',
        form.yearsOfExperience: '7',
        form.farmSize: '1200.5',
        form.farmSizeUnit: 'sq m',
        form.farmingType: 'Organic',
        form.mainCrops: 'Corn, Rice',
        form.irrigationType: 'Rainfed',
        form.ownershipType: 'Owned',
      };
      for (final entry in inputs.entries) {
        entry.key.text = ' ${entry.value} ';
      }
      form.profileImage = Uint8List.fromList([1, 2, 3]);
      form.farmImage = Uint8List.fromList([4, 5, 6]);
      final data = form.data();
      expect(data.toAuthMetadata(), {
        'requested_role': 'farmer',
        'first_name': 'Ana',
        'middle_name': 'Maria',
        'last_name': 'Reyes',
        'suffix': 'Jr.',
        'phone_number': '+639171234567',
        'date_of_birth': '1995-04-12',
        'gender': 'Female',
        'address_line': "12 O'Neil %_* Street",
        'barangay': 'Lapasan',
        'city_municipality': 'Cagayan de Oro',
        'province': 'Misamis Oriental',
        'postal_code': '9000',
        'farm_name': "Ana's Farm",
        'farm_location': 'Farm Road',
        'farm_barangay': 'Canitoan',
        'farm_city_municipality': 'Cagayan de Oro',
        'farm_province': 'Misamis Oriental',
        'latitude': 8.48,
        'longitude': 124.65,
        'years_of_experience': 7,
        'farm_size': 1200.5,
        'farm_size_unit': 'sq m',
        'farming_type': 'Organic',
        'irrigation_type': 'Rainfed',
        'ownership_type': 'Owned',
        'main_crops': ['Corn', 'Rice'],
        'total_crops': 2,
      });
      expect(data.profileImage, same(form.profileImage));
      expect(data.farmImage, same(form.farmImage));
      expect(data.toAuthMetadata(), isNot(contains('password')));
    },
  );
}

Future<void> _session(SupabaseClient client, {required bool verified}) =>
    client.auth.setInitialSession(
      jsonEncode({
        'access_token': 'test-token',
        'refresh_token': 'test-refresh',
        'token_type': 'bearer',
        'expires_in': 3600,
        'user': {
          'id': 'aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa',
          'aud': 'authenticated',
          'role': 'authenticated',
          'email': 'buyer@example.invalid',
          'created_at': '2026-01-01T00:00:00Z',
          if (verified) 'email_confirmed_at': '2026-01-01T00:00:00Z',
          'app_metadata': {},
          'user_metadata': {},
          'is_anonymous': false,
        },
      }),
    );

class _BuyerLoader extends SupabaseAccountLoader {
  _BuyerLoader(super.client);
  var loads = 0;
  @override
  Future<RegisteredAccount?> load() async {
    loads++;
    return const RegisteredAccount(
      id: 'aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa',
      firstName: 'Ana',
      lastName: 'Reyes',
      email: 'buyer@example.invalid',
      passwordHash: '',
      passwordSalt: '',
      role: 'buyer',
      accountStatus: 'active',
    );
  }
}
