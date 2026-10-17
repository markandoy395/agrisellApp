import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agresell_app/features/buyer/profile/data/buyer_avatar_repository.dart';
import 'support/supabase_session_fixture.dart';

void main() {
  final image = Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10, 0]);
  test(
    'buyer photo bytes use the protected API and return the persisted URL',
    () async {
      http.Request? sent;
      const url =
          'https://example.supabase.co/storage/v1/object/authenticated/buyer-avatars/owner/photo.png';
      final client = SupabaseClient(
        'https://example.supabase.co',
        'key',
        httpClient: MockClient((request) async {
          sent = request;
          return http.Response(
            jsonEncode({'url': url}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.dispose);
      await setTestSupabaseSession(client);
      expect(await BuyerAvatarRepository(client).save(image), url);
      expect(sent!.url.path, '/functions/v1/application-api/avatar');
      expect(
        sent!.headers['Content-Type'] ?? sent!.headers['content-type'],
        'image/png',
      );
      expect(sent!.bodyBytes, image);
    },
  );
  test(
    'signed-out and invalid image uploads make no network request',
    () async {
      var calls = 0;
      final client = SupabaseClient(
        'https://example.supabase.co',
        'key',
        httpClient: MockClient((request) async {
          calls++;
          return http.Response('{}', 200);
        }),
      );
      addTearDown(client.dispose);
      final repository = BuyerAvatarRepository(client);
      await expectLater(repository.save(image), throwsA(isA<AuthException>()));
      await setTestSupabaseSession(client);
      await expectLater(
        repository.save(Uint8List.fromList([1, 2, 3])),
        throwsFormatException,
      );
      expect(calls, 0);
    },
  );
}
