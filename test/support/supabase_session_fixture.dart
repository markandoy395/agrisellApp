import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> setTestSupabaseSession(
  SupabaseClient client, {
  String authId = 'aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa',
}) => client.auth.setInitialSession(
  jsonEncode({
    'access_token': 'test-access-token',
    'refresh_token': 'test-refresh-token',
    'token_type': 'bearer',
    'expires_in': 3600,
    'expires_at': DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600,
    'user': {
      'id': authId,
      'aud': 'authenticated',
      'role': 'authenticated',
      'email': 'ownership-test@example.invalid',
      'created_at': '2026-01-01T00:00:00Z',
      'app_metadata': {},
      'user_metadata': {},
      'is_anonymous': false,
    },
  }),
);
