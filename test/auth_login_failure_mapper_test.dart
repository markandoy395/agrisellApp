import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agresell_app/features/auth/data/auth_login_failure_mapper.dart';
import 'package:agresell_app/features/auth/data/auth_login_error_mapper.dart';

void main() {
  test('profile authorization failures never blame the internet', () {
    final failure = AuthLoginFailureMapper.map(
      const PostgrestException(message: 'private detail', code: '42501'),
    );
    expect(failure.message, contains('account profile'));
    expect(failure.message, isNot(contains('internet')));
    expect(failure.message, isNot(contains('private detail')));
  });

  test('connection and timeout errors identify the unreachable service', () {
    for (final error in [
      http.ClientException('secret detail'),
      TimeoutException('detail'),
    ]) {
      final message = AuthLoginFailureMapper.map(error).message;
      expect(message, contains('could not reach'));
      expect(message, isNot(contains('secret detail')));
    }
  });

  test('429 responses are shown as limits for authentication and profiles', () {
    expect(
      AuthLoginErrorMapper.toRegistrationException(
        const AuthException('rate', statusCode: '429'),
      ).message,
      contains('Too many login attempts'),
    );
    expect(
      AuthLoginFailureMapper.map(
        const PostgrestException(message: 'rate', code: '429'),
      ).message,
      contains('Too many requests'),
    );
  });

  test(
    'invalid application keys and server outages have distinct messages',
    () {
      expect(
        AuthLoginErrorMapper.toRegistrationException(
          const AuthException('key', statusCode: '401'),
        ).message,
        contains('authorize this app'),
      );
      expect(
        AuthLoginErrorMapper.toRegistrationException(
          const AuthException('server', statusCode: '503'),
        ).message,
        contains('temporarily unavailable'),
      );
    },
  );
}
