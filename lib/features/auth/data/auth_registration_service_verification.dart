part of 'auth_registration_service.dart';

extension AuthRegistrationServiceVerification on AuthRegistrationService {
  /// Starts the credentials-first signup flow and returns true when the user
  /// must enter the Supabase signup OTP before adding profile information.
  Future<bool> startEmailVerification({
    required String email,
    required String password,
    required AuthRole role,
  }) async {
    final starter = _emailStarterForTesting;
    if (starter != null) return starter(email, password, role);
    if (!usesSupabase) {
      _requireConfiguredBackend();
      return false;
    }
    try {
      return await _remote.startEmailVerification(
        email: email,
        password: password,
        role: role,
      );
    } on AuthRegistrationException {
      rethrow;
    } on AuthException catch (error) {
      throw AuthOtpErrorMapper.signUp(error);
    } catch (_) {
      throw const AuthRegistrationException(
        'We could not send the email OTP. Please try again.',
      );
    }
  }

  Future<RegisteredAccount> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    if (!usesSupabase) {
      throw const AuthRegistrationException(
        'Email verification is temporarily unavailable. Please try again later.',
      );
    }
    try {
      _remoteAccount = await _remote.verifyEmailOtp(email: email, otp: otp);
      return _remoteAccount!;
    } on AuthRegistrationException {
      rethrow;
    } on AuthException catch (error) {
      throw AuthOtpErrorMapper.verification(error);
    } catch (_) {
      throw const AuthRegistrationException(
        'We could not verify the email OTP. Please try again.',
      );
    }
  }

  Future<RegisteredAccount> verifySignupEmailOtp({
    required String email,
    required String otp,
    required AuthRole role,
  }) async {
    final account = await verifyEmailOtp(email: email, otp: otp);
    if (account.profilePending && account.assignedRole == role) return account;
    await signOut();
    throw const AuthRegistrationException(
      'This email is already registered. Log in or use another email.',
    );
  }

  Future<void> resendSignupEmailOtp(String email) async {
    if (!usesSupabase) {
      throw const AuthRegistrationException(
        'Email verification is temporarily unavailable. Please try again later.',
      );
    }
    try {
      await _remote.resendSignupEmailOtp(email);
    } on AuthException catch (error) {
      throw AuthOtpErrorMapper.delivery(error);
    } catch (_) {
      throw const AuthRegistrationException(
        'We could not resend the email OTP. Please try again.',
      );
    }
  }
}
