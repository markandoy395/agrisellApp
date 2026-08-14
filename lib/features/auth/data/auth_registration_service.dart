import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/auth/data/auth_login_error_mapper.dart';
import 'package:agresell_app/features/auth/data/auth_otp_error_mapper.dart';
import 'package:agresell_app/features/auth/data/auth_registration_exception.dart';
import 'package:agresell_app/features/auth/data/local_auth_registration_store.dart';
import 'package:agresell_app/features/auth/data/supabase_auth_service.dart';
import 'package:agresell_app/features/auth/domain/buyer_shipping_address.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/farmer/registration/data/farmer_registration_service.dart';
import 'package:agresell_app/features/farmer/registration/domain/farmer_signup_data.dart';

export 'package:agresell_app/features/auth/data/auth_registration_exception.dart';

class AuthRegistrationService {
  AuthRegistrationService._();

  static final AuthRegistrationService instance = AuthRegistrationService._();

  final LocalAuthRegistrationStore _local = LocalAuthRegistrationStore();
  static const SupabaseAuthService _remote = SupabaseAuthService();
  RegisteredAccount? _remoteAccount;
  bool _localStoreEnabledForTesting = false;

  bool get usesSupabase => AgrisellSupabase.isInitialized;

  String? get currentRefreshToken =>
      usesSupabase ? _remote.currentRefreshToken : null;

  List<RegisteredAccount> get registeredAccounts {
    if (!usesSupabase) return _local.accounts;
    final account = _remoteAccount;
    return account == null
        ? const <RegisteredAccount>[]
        : List<RegisteredAccount>.unmodifiable([account]);
  }

  Future<RegisteredAccount?> authenticate(
    String identifier,
    String password,
  ) async {
    if (!usesSupabase) {
      _requireConfiguredBackend();
      return _local.authenticate(identifier, password);
    }
    try {
      _remoteAccount = await _remote.authenticate(identifier, password);
      return _remoteAccount;
    } on AuthRegistrationException {
      rethrow;
    } on AuthException catch (error) {
      if (AuthLoginErrorMapper.isInvalidCredentials(error)) return null;
      throw AuthLoginErrorMapper.toRegistrationException(error);
    } catch (_) {
      throw const AuthRegistrationException(
        "We couldn't sign you in right now. Please check your internet "
        'connection and try again.',
      );
    }
  }

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

  Future<RegisteredAccount> register(SignUpAccountData data, AuthRole role) =>
      _register(data, role);

  Future<RegisteredAccount> registerFarmer(FarmerSignupData data) async {
    if (!usesSupabase) {
      _requireConfiguredBackend();
      return _local.register(
        SignUpAccountData(
          firstName: data.firstName,
          lastName: data.lastName,
          email: data.email,
          password: data.password,
          extensionName: data.suffix,
          middleName: data.middleName,
          phoneNumber: data.phoneNumber,
          dateOfBirth: data.dateOfBirth,
          gender: data.gender,
        ),
        AuthRole.farmer,
      );
    }
    try {
      _remoteAccount = await const FarmerRegistrationService().register(data);
      return _remoteAccount!;
    } on AuthRegistrationException {
      rethrow;
    } on AuthException catch (error) {
      throw AuthOtpErrorMapper.signUp(error);
    } catch (_) {
      throw const AuthRegistrationException(
        'Farmer registration could not be completed. Please try again.',
      );
    }
  }

  Future<RegisteredAccount> completeVerifiedFarmerRegistration(
    FarmerSignupData data,
  ) async {
    if (!usesSupabase) {
      throw const AuthRegistrationException(
        'Email verification is temporarily unavailable. Please try again later.',
      );
    }
    try {
      _remoteAccount = await const FarmerRegistrationService()
          .completeVerifiedRegistration(data);
      return _remoteAccount!;
    } on AuthRegistrationException {
      rethrow;
    } on PostgrestException catch (error) {
      throw AuthRegistrationException(error.message);
    } catch (_) {
      throw const AuthRegistrationException(
        'Farmer registration could not be completed after verification.',
      );
    }
  }

  Future<RegisteredAccount> registerRider(
    SignUpAccountData data,
    Map<String, Object?> application,
  ) => _register(data, AuthRole.rider, riderApplication: application);

  Future<RegisteredAccount> _register(
    SignUpAccountData data,
    AuthRole role, {
    Map<String, Object?>? riderApplication,
  }) async {
    if (!usesSupabase) {
      _requireConfiguredBackend();
      return _local.register(
        data,
        role,
        isRiderApplication: riderApplication != null,
      );
    }
    try {
      _remoteAccount = await _remote.register(
        data,
        role,
        riderApplication: riderApplication,
      );
      return _remoteAccount!;
    } on AuthRegistrationException {
      rethrow;
    } on AuthException catch (error) {
      throw AuthOtpErrorMapper.signUp(error);
    } catch (_) {
      throw const AuthRegistrationException(
        "We couldn't create your account right now. Please try again.",
      );
    }
  }

  Future<RegisteredAccount?> loadCurrentAccount() async {
    if (!usesSupabase) return null;
    try {
      _remoteAccount = await _remote.loadCurrentAccount();
      return _remoteAccount;
    } catch (_) {
      return null;
    }
  }

  Future<RegisteredAccount?> restoreSavedSession(String refreshToken) async {
    if (!usesSupabase) return null;
    _remoteAccount = await _remote.restoreSession(refreshToken);
    return _remoteAccount;
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

  Future<RegisteredAccount> saveBuyerShippingAddress(
    RegisteredAccount account,
    BuyerShippingAddress address,
  ) async {
    if (account.assignedRole != AuthRole.buyer) {
      throw const AuthRegistrationException(
        'Only buyers can set shipping addresses.',
      );
    }
    if (!usesSupabase) {
      final saved = _local.updateShippingAddress(
        account.id,
        address.address,
        latitude: address.latitude,
        longitude: address.longitude,
      );
      if (saved != null) return saved;
      throw const AuthRegistrationException('Your account could not be found.');
    }
    try {
      final savedAddress = await _remote.saveBuyerShippingAddress(address);
      final saved = account.copyWith(
        shippingAddress: savedAddress.address,
        shippingLatitude: savedAddress.latitude,
        shippingLongitude: savedAddress.longitude,
      );
      _remoteAccount = saved;
      return saved;
    } on AuthException catch (error) {
      throw AuthRegistrationException(error.message);
    } on PostgrestException catch (error) {
      throw AuthRegistrationException(error.message);
    } catch (_) {
      throw const AuthRegistrationException(
        'Your shipping address could not be saved. Please retry.',
      );
    }
  }

  Future<void> signOut() async {
    if (usesSupabase) await _remote.signOut();
    _remoteAccount = null;
  }

  void clearForTesting() {
    _localStoreEnabledForTesting = true;
    _local.clear();
    _remoteAccount = null;
  }

  void _requireConfiguredBackend() {
    if (_localStoreEnabledForTesting) return;
    throw const AuthRegistrationException(
      "We couldn't connect to AgriSell right now. Please check your internet "
      'connection and try again.',
    );
  }

  RegisteredAccount? accountById(String id) {
    if (_remoteAccount?.id == id) return _remoteAccount;
    return _local.accountById(id);
  }
}
