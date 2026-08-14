import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/features/auth/data/auth_registration_exception.dart';

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
    return const AuthRegistrationException(
      "We couldn't sign you in right now. Please check your internet "
      'connection and try again.',
    );
  }
}
