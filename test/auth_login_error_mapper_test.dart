import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/features/auth/data/auth_login_error_mapper.dart';
import 'package:agresell_app/features/auth/data/auth_registration_service.dart';

void main() {
  test('an unconfigured app does not check an empty local account store', () {
    expect(
      AuthRegistrationService.instance.authenticate(
        'buyer@example.com',
        'correct-password',
      ),
      throwsA(
        isA<AuthRegistrationException>().having(
          (error) => error.message,
          'message',
          contains('missing its sign-in configuration'),
        ),
      ),
    );
  });

  test('only invalid credentials are treated as a credential mismatch', () {
    const invalidCredentials = AuthException(
      'Invalid login credentials',
      statusCode: '400',
      code: 'invalid_credentials',
    );
    const backendFailure = AuthException(
      'Invalid API key',
      statusCode: '401',
      code: 'bad_jwt',
    );

    expect(AuthLoginErrorMapper.isInvalidCredentials(invalidCredentials), true);
    expect(AuthLoginErrorMapper.isInvalidCredentials(backendFailure), false);
  });

  test('unconfirmed email receives an actionable login message', () {
    const error = AuthException(
      'Email not confirmed',
      statusCode: '400',
      code: 'email_not_confirmed',
    );

    final mapped = AuthLoginErrorMapper.toRegistrationException(error);
    expect(mapped, isA<AuthEmailNotVerified>());
    expect(
      mapped.message,
      'Please verify your email address before signing in.',
    );
  });

  test('unexpected auth failures are not reported as a wrong password', () {
    const error = AuthException('Connection failed');

    expect(
      AuthLoginErrorMapper.toRegistrationException(error).message,
      contains("couldn't sign you in"),
    );
  });
}
