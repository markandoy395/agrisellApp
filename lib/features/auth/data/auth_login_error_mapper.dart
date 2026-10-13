import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/features/auth/data/auth_registration_exception.dart';
import 'auth_login_failure_mapper.dart';

class AuthLoginErrorMapper {
  const AuthLoginErrorMapper._();

  static bool isInvalidCredentials(AuthException error) {
    final code = error.code?.trim().toLowerCase();
    if (code == 'invalid_credentials') return true;
    return error.message.toLowerCase().contains('invalid login credentials');
  }

  static AuthRegistrationException toRegistrationException(
    AuthException error,
  ) {
    AuthLoginFailureMapper.diagnose(
      'authentication',
      error.code ?? error.statusCode,
    );
    if (error.statusCode == '429') {
      return const AuthRegistrationException(
        'Too many login attempts. Please wait and try again.',
      );
    }
    switch (error.code?.trim().toLowerCase()) {
      case 'email_not_confirmed':
        return const AuthEmailNotVerified();
      case 'user_banned':
        return const AuthRegistrationException(
          'This account is unavailable. Please contact support.',
        );
      case 'over_request_rate_limit':
        return const AuthRegistrationException(
          'Too many login attempts. Please wait and try again.',
        );
    }
    if (error.statusCode == '401' ||
        error.code == 'bad_jwt' ||
        error.code == 'bad_jwt_signature') {
      return const AuthRegistrationException(
        'The sign-in service could not authorize this app. Please update '
        'AgriSell or contact support.',
      );
    }
    if (int.tryParse(error.statusCode ?? '') case final status?
        when status >= 500) {
      return const AuthRegistrationException(
        'The sign-in service is temporarily unavailable. Please try again later.',
      );
    }
    return const AuthRegistrationException(
      "We couldn't sign you in right now. Please try again or contact support.",
    );
  }
}
