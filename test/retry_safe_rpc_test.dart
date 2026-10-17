import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agresell_app/core/services/retry_safe_rpc.dart';
import 'support/supabase_session_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'uncertain gateway response reuses retry key and preserves literal data',
    () async {
      final keys = <String>[];
      var status = 503;
      final client = SupabaseClient(
        'https://project.supabase.co',
        'test-key',
        httpClient: MockClient((request) async {
          expect(
            request.url.path,
            '/functions/v1/application-api/rest/rpc/submit_farmer_payout_once',
          );
          final data = jsonDecode(request.body) as Map;
          keys.add(data['p_request_key'] as String);
          expect(data['p_notes'], "literal_%_'--");
          expect(data.containsKey('user_id'), isFalse);
          return http.Response(
            jsonEncode(
              status == 200 ? {'requestId': 'saved'} : {'error': 'Unavailable'},
            ),
            status,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.dispose);
      await setTestSupabaseSession(client);
      final params = <String, Object?>{
        'p_amount': 25,
        'p_notes': "literal_%_'--",
      };
      await expectLater(
        RetrySafeRpc.call(client, 'submit_farmer_payout_once', params),
        throwsA(isA<PostgrestException>()),
      );
      status = 200;
      expect(
        await RetrySafeRpc.call(client, 'submit_farmer_payout_once', params),
        {'requestId': 'saved'},
      );
      expect(keys[0], keys[1]);
      await RetrySafeRpc.call(client, 'submit_farmer_payout_once', params);
      expect(keys[2], isNot(keys[1]));
    },
  );
  test('signed out caller cannot dispatch a protected write', () async {
    var calls = 0;
    final client = SupabaseClient(
      'https://project.supabase.co',
      'test-key',
      httpClient: MockClient((request) async {
        calls++;
        return http.Response('{}', 200);
      }),
    );
    addTearDown(client.dispose);
    expect(
      () => RetrySafeRpc.call(client, 'submit_farmer_payout_once', {}),
      throwsA(isA<AuthException>()),
    );
    expect(calls, 0);
  });
}
