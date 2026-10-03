import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/auth/data/auth_registration_exception.dart';
import 'package:agresell_app/features/auth/data/buyer_shipping_address_repository.dart';
import 'package:agresell_app/features/auth/data/supabase_account_loader.dart';
import 'package:agresell_app/features/auth/data/supabase_email_verification_handler.dart';
import 'package:agresell_app/features/auth/data/supabase_registration_handler.dart';
import 'package:agresell_app/features/auth/domain/buyer_shipping_address.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';

class SupabaseAuthService {
  const SupabaseAuthService();

  SupabaseClient get _client => AgrisellSupabase.client;

  SupabaseAccountLoader get _accountLoader => SupabaseAccountLoader(_client);

  SupabaseRegistrationHandler get _registrationHandler =>
      SupabaseRegistrationHandler(_client, accountLoader: _accountLoader);

  SupabaseEmailVerificationHandler get _emailVerificationHandler =>
      SupabaseEmailVerificationHandler(_client, accountLoader: _accountLoader);

  String? get currentRefreshToken => _client.auth.currentSession?.refreshToken;

  Future<RegisteredAccount?> authenticate(
    String identifier,
    String password,
  ) async {
    final value = identifier.trim();
    if (!value.contains('@')) return null;
    final response = await _client.auth.signInWithPassword(
      email: value.toLowerCase(),
      password: password,
    );
    if (response.user == null) return null;
    final account = await loadCurrentAccount();
    if (account == null) {
      throw const AuthRegistrationException(
        'The account profile could not be loaded.',
      );
    }
    return account;
  }

  Future<RegisteredAccount> register(
    SignUpAccountData data,
    AuthRole role, {
    Map<String, Object?>? riderApplication,
  }) => _registrationHandler.register(
    data,
    role,
    riderApplication: riderApplication,
  );

  Future<bool> startEmailVerification({
    required String email,
    required String password,
    required AuthRole role,
  }) => _emailVerificationHandler.startEmailVerification(
    email: email,
    password: password,
    role: role,
  );

  Future<RegisteredAccount?> loadCurrentAccount() => _accountLoader.load();

  Future<RegisteredAccount?> restoreSession(String refreshToken) async {
    final response = await _client.auth.setSession(refreshToken);
    if (response.user == null) return null;
    return loadCurrentAccount();
  }

  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    await _client.auth.signInWithPassword(
      email: email.trim().toLowerCase(),
      password: currentPassword,
    );
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<RegisteredAccount> completeVerifiedBuyerRegistration(
    SignUpAccountData data,
  ) => _registrationHandler.completeVerifiedBuyerRegistration(data);

  Future<RegisteredAccount> verifyEmailOtp({
    required String email,
    required String otp,
  }) => _emailVerificationHandler.verifyEmailOtp(email: email, otp: otp);

  Future<void> resendSignupEmailOtp(String email) =>
      _emailVerificationHandler.resendSignupEmailOtp(email);

  Future<void> requestPasswordReset(String email) =>
      _client.auth.resetPasswordForEmail(email.trim().toLowerCase());

  Future<void> verifyPasswordRecoveryOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _client.auth.verifyOTP(
      email: email.trim().toLowerCase(),
      token: otp.trim(),
      type: OtpType.recovery,
    );
    if (response.session == null) {
      throw const AuthRegistrationException(
        'The password-reset OTP is invalid or expired.',
      );
    }
  }

  Future<void> updatePasswordAfterRecovery(String password) =>
      _client.auth.updateUser(UserAttributes(password: password));

  Future<void> resendPasswordRecoveryOtp(String email) => _client.auth.resend(
    type: OtpType.recovery,
    email: email.trim().toLowerCase(),
  );

  Future<BuyerShippingAddress> saveBuyerShippingAddress(
    BuyerShippingAddress address,
  ) => BuyerShippingAddressRepository(_client).save(address);
}
