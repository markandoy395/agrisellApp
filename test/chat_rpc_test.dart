import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agresell_app/features/shared/chat/data/chat_rpc.dart';

void main() {
  for (final status in [200, 429, 503]) {
    test(
      'protected chat transport preserves request and $status response',
      () async {
        final client = SupabaseClient(
          'https://project.supabase.co',
          'test-key',
          accessToken: () async => 'caller-token',
          httpClient: MockClient((request) async {
            expect(
              request.url.path,
              '/functions/v1/application-api/rest/rpc/send_marketplace_message',
            );
            expect(request.headers['authorization'], 'Bearer caller-token');
            expect(jsonDecode(request.body), {
              'conversation_id': 12,
              'body': "literal %_' --",
            });
            return http.Response(
              jsonEncode(
                status == 200
                    ? {'message_id': 1}
                    : {'error': 'Chat limit reached.'},
              ),
              status,
              headers: {'content-type': 'application/json'},
            );
          }),
        );
        addTearDown(client.dispose);
        final result = ChatRpc.call(client, 'send_marketplace_message', {
          'conversation_id': 12,
          'body': "literal %_' --",
        });
        if (status == 200)
          expect(await result, {'message_id': 1});
        else
          await expectLater(
            result,
            throwsA(
              isA<PostgrestException>().having(
                (error) => error.code,
                'code',
                '$status',
              ),
            ),
          );
      },
    );
  }
}
