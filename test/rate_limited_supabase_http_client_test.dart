import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:agresell_app/core/services/rate_limited_supabase_http_client.dart';

void main() {
  test(
    'REST relay retains bound parameters, caller token and 429 response',
    () async {
      final client = RateLimitedSupabaseHttpClient(
        projectUrl: 'https://project.supabase.co',
        inner: MockClient((request) async {
          expect(
            request.url.path,
            '/functions/v1/application-api/rest/rpc/save',
          );
          expect(request.url.queryParameters['select'], 'id');
          expect(request.headers['authorization'], 'Bearer user-token');
          expect(request.body, '{"value":"\u0027; DROP TABLE users;--"}');
          return http.Response('limited', 429, headers: {'retry-after': '30'});
        }),
      );
      addTearDown(client.close);
      final response = await client.post(
        Uri.parse('https://project.supabase.co/rest/v1/rpc/save?select=id'),
        headers: {'authorization': 'Bearer user-token'},
        body: '{"value":"\u0027; DROP TABLE users;--"}',
      );
      expect(response.statusCode, 429);
      expect(response.headers['retry-after'], '30');
    },
  );

  test('auth, storage and foreign origins are not redirected', () async {
    for (final target in [
      'https://project.supabase.co/auth/v1/token',
      'https://project.supabase.co/storage/v1/object/private/file',
      'https://other.example/rest/v1/users',
    ]) {
      final client = RateLimitedSupabaseHttpClient(
        projectUrl: 'https://project.supabase.co',
        inner: MockClient((request) async {
          expect(request.url.toString(), target);
          return http.Response('', 200);
        }),
      );
      addTearDown(client.close);
      await client.get(Uri.parse(target));
    }
  });
}
