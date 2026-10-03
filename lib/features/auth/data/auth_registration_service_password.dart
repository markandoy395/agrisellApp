part of 'auth_registration_service.dart';

extension AuthRegistrationServicePassword on AuthRegistrationService {
  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    if (newPassword.length < 8) {
      throw const AuthRegistrationException(
        'Use a password with at least 8 characters.',
      );
    }
    if (!usesSupabase) {
      _requireConfiguredBackend();
      return _local.changePassword(
        email: email,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    }
    try {
      await _remote.changePassword(
        email: email,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } on AuthException catch (error) {
      throw AuthRegistrationException(error.message);
    }
  }

  Future<void> requestPasswordReset(String email) async {
    if (!usesSupabase) {
      throw const AuthRegistrationException(
        'Password reset is temporarily unavailable. Please try again later.',
      );
    }
    try {
      await _remote.requestPasswordReset(email);
    } on AuthException catch (error) {
      throw AuthRegistrationException(error.message);
    } catch (_) {
      throw const AuthRegistrationException(
        'We could not send the password-reset OTP. Please try again.',
      );
    }
  }

  Future<void> verifyPasswordRecoveryOtp({
    required String email,
    required String otp,
  }) async {
    try {
      await _remote.verifyPasswordRecoveryOtp(email: email, otp: otp);
    } on AuthRegistrationException {
      rethrow;
    } on AuthException catch (error) {
      throw AuthRegistrationException(error.message);
    } catch (_) {
      throw const AuthRegistrationException(
        'We could not verify the password-reset OTP. Please try again.',
      );
    }
  }

  Future<void> completePasswordRecovery(String password) async {
    if (!usesSupabase) {
      throw const AuthRegistrationException(
        'Password reset is temporarily unavailable. Please try again later.',
      );
    }
    try {
      await _remote.updatePasswordAfterRecovery(password);
      await _remote.signOut();
      _remoteAccount = null;
    } on AuthException catch (error) {
      throw AuthRegistrationException(error.message);
    } catch (_) {
      throw const AuthRegistrationException(
        'We could not update your password. Please try again.',
      );
    }
  }

  Future<void> resendPasswordRecoveryOtp(String email) async {
    try {
      await _remote.resendPasswordRecoveryOtp(email);
    } on AuthException catch (error) {
      throw AuthRegistrationException(error.message);
    } catch (_) {
      throw const AuthRegistrationException(
        'We could not resend the password-reset OTP. Please try again.',
      );
    }
  }
}
