class RiderRegistrationException implements Exception {
  const RiderRegistrationException(this.message);
  final String message;
  @override
  String toString() => message;
}

class RiderEmailOtpRequired extends RiderRegistrationException {
  const RiderEmailOtpRequired(String email)
    : super('Enter the OTP sent to $email to finish your Rider sign-up.');
}
