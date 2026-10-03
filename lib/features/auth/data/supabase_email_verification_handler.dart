import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/features/auth/data/auth_registration_exception.dart';
import 'package:agresell_app/features/auth/data/supabase_account_loader.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';

/// Handles email verification flows, signup probing, and OTP confirmations.
class SupabaseEmailVerificationHandler {
  SupabaseEmailVerificationHandler(
    this._client, {
    SupabaseAccountLoader? accountLoader,
  }) : _accountLoader = accountLoader ?? SupabaseAccountLoader(_client);

  final SupabaseClient _client;
  final SupabaseAccountLoader _accountLoader;

  Future<bool> startEmailVerification({
    required String email,
    required String password,
    required AuthRole role,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final currentUser = _client.auth.currentUser;
    if (currentUser?.email?.trim().toLowerCase() == normalizedEmail &&
        currentUser?.emailConfirmedAt != null) {
      final existing = await _accountLoader.load();
      if (existing?.profilePending == true && existing?.assignedRole == role) {
        throw const AuthIncompleteRegistrationFound(emailVerified: true);
      }
      throw const AuthRegistrationException(
        'This email is already registered. Log in or use another email.',
      );
    }

    AuthResponse response;
    try {
      response = await _client.auth.signUp(
        email: normalizedEmail,
        password: password,
        data: <String, Object?>{
          'requested_role': role.value,
          'signup_stage': 'profile_pending',
        },
      );
    } on AuthException catch (error) {
      final code = error.code?.toLowerCase();
      final message = error.message.toLowerCase();
      if (code == 'user_already_exists' ||
          code == 'email_exists' ||
          message.contains('already registered') ||
          message.contains('already exists')) {
        return await _probeExistingSignup(normalizedEmail, password, role);
      }
      rethrow;
    }

    final user = response.user;
    if (user == null) {
      throw const AuthRegistrationException('Account creation failed.');
    }
    if (user.identities?.isEmpty == true) {
      return await _probeExistingSignup(normalizedEmail, password, role);
    }
    if (response.session != null) {
      await _client.auth.signOut();
      throw const AuthRegistrationException(
        'Email OTP verification is disabled for this AgriSell project. '
        'Enable Confirm email in Supabase Authentication settings, then try '
        'again with a new email.',
      );
    }
    return true;
  }

  Future<Never> _probeExistingSignup(
    String email,
    String password,
    AuthRole role,
  ) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      final existing = await _accountLoader.load();
      if (existing?.profilePending == true && existing?.assignedRole == role) {
        throw const AuthIncompleteRegistrationFound(emailVerified: true);
      }
      await _client.auth.signOut();
      throw const AuthRegistrationException(
        'This email is already registered. Log in or use another email.',
      );
    } on AuthRegistrationException {
      rethrow;
    } on AuthException catch (error) {
      if (error.code?.toLowerCase() == 'email_not_confirmed') {
        throw const AuthIncompleteRegistrationFound(emailVerified: false);
      }
      throw const AuthRegistrationException(
        'This email is already registered. Log in or use another email.',
      );
    }
  }

  Future<RegisteredAccount> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedOtp = otp.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(normalizedOtp)) {
      throw const AuthOtpException(
        'That OTP is invalid. Enter the 6 digits from your email.',
        reason: AuthOtpFailureReason.invalid,
      );
    }

    final response = await _client.auth.verifyOTP(
      email: normalizedEmail,
      token: normalizedOtp,
      type: OtpType.email,
    );

    if (response.session == null || response.user?.emailConfirmedAt == null) {
      throw const AuthRegistrationException(
        'The email could not be confirmed. Request a new OTP and try again.',
      );
    }

    final account = await _accountLoader.load();
    if (account == null) {
      throw const AuthRegistrationException(
        'Your email was verified, but the account could not be completed.',
      );
    }
    return account;
  }

  Future<void> resendSignupEmailOtp(String email) => _client.auth.resend(
    type: OtpType.signup,
    email: email.trim().toLowerCase(),
  );
}
