import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/auth/data/auth_login_error_mapper.dart';
import 'package:agresell_app/features/auth/data/auth_login_failure_mapper.dart';
import 'package:agresell_app/features/auth/data/auth_otp_error_mapper.dart';
import 'package:agresell_app/features/auth/data/auth_registration_exception.dart';
import 'package:agresell_app/features/auth/data/local_auth_registration_store.dart';
import 'package:agresell_app/features/auth/data/supabase_auth_service.dart';
import 'package:agresell_app/features/auth/domain/buyer_shipping_address.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/farmer/registration/data/farmer_registration_service.dart';
import 'package:agresell_app/features/farmer/registration/domain/farmer_signup_data.dart';

export 'package:agresell_app/features/auth/data/auth_registration_exception.dart';

part 'auth_registration_service_password.dart';
part 'auth_registration_service_registration.dart';
part 'auth_registration_service_verification.dart';

class AuthRegistrationService {
  AuthRegistrationService._();

  static final AuthRegistrationService instance = AuthRegistrationService._();

  final LocalAuthRegistrationStore _local = LocalAuthRegistrationStore();
  final SupabaseAuthService _remote = const SupabaseAuthService();
  RegisteredAccount? _remoteAccount;
  bool _localStoreEnabledForTesting = false;
  Future<bool> Function(String, String, AuthRole)? _emailStarterForTesting;

  bool get usesSupabase => AgrisellSupabase.isInitialized;
  bool get localStoreEnabledForTesting => _localStoreEnabledForTesting;

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
    } catch (error) {
      throw AuthLoginFailureMapper.map(error);
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

  Future<void> signOut() async {
    if (usesSupabase) await _remote.signOut();
    _remoteAccount = null;
  }

  void clearForTesting() {
    _localStoreEnabledForTesting = true;
    _local.clear();
    _remoteAccount = null;
    _emailStarterForTesting = null;
  }

  @visibleForTesting
  void setCurrentAccountForTesting(RegisteredAccount account) {
    if (!_localStoreEnabledForTesting || usesSupabase) {
      throw StateError('Account fixtures require local testing mode.');
    }
    _remoteAccount = account;
  }

  void setEmailStarterForTesting(
    Future<bool> Function(String, String, AuthRole)? starter,
  ) => _emailStarterForTesting = starter;

  void _requireConfiguredBackend() {
    if (_localStoreEnabledForTesting) return;
    AuthLoginFailureMapper.diagnose('configuration', 'missing_backend');
    throw const AuthRegistrationException(
      'This installation is missing its sign-in configuration. Please update '
      'AgriSell or contact support.',
    );
  }

  RegisteredAccount? accountById(String id) {
    if (_remoteAccount?.id == id) return _remoteAccount;
    return _local.accountById(id);
  }
}
