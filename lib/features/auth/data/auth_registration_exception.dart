class AuthRegistrationException implements Exception {
  const AuthRegistrationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthEmailConfirmationRequired extends AuthRegistrationException {
  const AuthEmailConfirmationRequired()
    : super(
        'We sent an OTP to your email. Verify it, then log in to finish signing up.',
      );
}
