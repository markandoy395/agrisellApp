class AuthRegistrationException implements Exception {
  const AuthRegistrationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthEmailConfirmationRequired extends AuthRegistrationException {
  const AuthEmailConfirmationRequired()
    : super('We sent a 6-digit OTP to your email.');
}

class AuthEmailNotVerified extends AuthRegistrationException {
  const AuthEmailNotVerified()
    : super('Please verify your email address before signing in.');
}

enum AuthOtpFailureReason {
  invalid,
  expired,
  tooManyAttempts,
  deliveryFailed,
  alreadyVerified,
  unavailable,
}

class AuthOtpException extends AuthRegistrationException {
  const AuthOtpException(super.message, {required this.reason});

  final AuthOtpFailureReason reason;
}
