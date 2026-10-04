import 'dart:convert';
import 'package:agresell_app/features/buyer/cart/data/checkout_voucher_lookup.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'support/supabase_session_fixture.dart';

void main() {
  for (final code in [
    "' OR 1=1 --",
    "x'); DROP TABLE users; --",
    '%,_*,promo_code.eq.OTHER',
    r'backslash\and"quotes',
    'NormalCode',
  ]) {
    test('voucher input stays a literal RPC value: $code', () async {
      http.Request? captured;
      final client = SupabaseClient(
        'https://example.supabase.co',
        'test-key',
        httpClient: MockClient((request) async {
          captured = request;
          return http.Response(
            'null',
            200,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }),
      );
      addTearDown(client.dispose);
      await setTestSupabaseSession(client);
      expect(await CheckoutVoucherLookup(client).load(code), isNull);
      expect(captured!.method, 'POST');
      expect(captured!.url.path, '/rest/v1/rpc/current_checkout_voucher');
      expect(captured!.url.queryParameters, isEmpty);
      expect(jsonDecode(captured!.body), {'p_code': code});
    });
  }
}
