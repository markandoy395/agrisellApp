import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/core/services/push_notification_service.dart';
import 'package:agresell_app/features/auth/data/account_session_store.dart';
import 'package:agresell_app/features/auth/data/authRegistrationService.dart';
import 'package:agresell_app/features/auth/domain/saved_account.dart';
import 'package:agresell_app/features/auth/domain/signUpAccountData.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/buyer/home/presentation/controllers/farmer_follow_controller.dart';
import 'package:agresell_app/features/rider/profile/data/rider_registration_service.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';

part 'auth_session_service_lifecycle.dart';

class AuthSessionRestoreResult {
  const AuthSessionRestoreResult({
    required this.account,
    required this.wasExpired,
  });

  const AuthSessionRestoreResult.noSession()
    : account = null,
      wasExpired = false;

  const AuthSessionRestoreResult.expired() : account = null, wasExpired = true;

  final RegisteredAccount? account;
  final bool wasExpired;
}

class SavedAccountSessionException implements Exception {
  const SavedAccountSessionException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthSessionService {
  AuthSessionService._();

  static final AuthSessionService instance = AuthSessionService._();
  static const _accountIdKey = 'auth.session.account-id';

  final AccountSessionStore _sessionStore = AccountSessionStore();
  StreamSubscription<AuthState>? _authSubscription;
  String? _currentAccountId;
  bool _currentAccountRemembered = false;

  RegisteredAccount? get currentAccount => _currentAccountId == null
      ? null
      : AuthRegistrationService.instance.accountById(_currentAccountId!);

  Future<List<SavedAccount>> availableAccounts() async {
    final accounts = await _sessionStore.loadAccounts();
    final current = currentAccount;
    if (current == null || accounts.any((item) => item.id == current.id)) {
      return accounts;
    }
    return [SavedAccount.fromAccount(current), ...accounts];
  }

  Future<void> start(
    RegisteredAccount account, {
    required bool rememberMe,
  }) async {
    await _activate(account);
    if (!rememberMe) {
      await _clearPersistedAccount();
      return;
    }
    await _remember(account);
    await _persistActiveAccount(account.id);
    _currentAccountRemembered = true;
  }

  Future<RegisteredAccount> switchTo(String accountId) async {
    if (accountId == _currentAccountId) {
      final account = currentAccount;
      if (account != null) return account;
    }
    final saved = await _sessionStore.loadAccounts();
    final selected = saved.where((item) => item.id == accountId).firstOrNull;
    if (selected == null) {
      throw const SavedAccountSessionException(
        'This account is no longer saved on this device.',
      );
    }

    await BasketController.instance.flush();
    late final RegisteredAccount? account;
    if (AuthRegistrationService.instance.usesSupabase) {
      final credential = await _sessionStore.readCredential(accountId);
      if (credential == null || credential.isEmpty) {
        throw SavedAccountSessionException(
          'Sign in to ${selected.email} again to restore this account.',
        );
      }
      try {
        account = await AuthRegistrationService.instance.restoreSavedSession(
          credential,
        );
      } on AuthException {
        throw SavedAccountSessionException(
          'The saved session for ${selected.email} expired. Sign in again.',
        );
      }
    } else {
      account = AuthRegistrationService.instance.accountById(accountId);
    }
    if (account == null || account.id != accountId) {
      throw SavedAccountSessionException(
        'The saved session for ${selected.email} is unavailable.',
      );
    }

    await _activate(account);
    await _remember(account);
    await _persistActiveAccount(account.id);
    _currentAccountRemembered = true;
    return account;
  }

  Future<void> _activate(RegisteredAccount account) async {
    if (_currentAccountId != null && _currentAccountId != account.id) {
      _clearAccountState();
    }
    _currentAccountId = account.id;
    _currentAccountRemembered = false;
    _ensureAuthListener();
    await OrderController.instance.loadForAccount(account.id);
    unawaited(PushNotificationService.instance.registerForUser(account.id));
  }

  Future<void> _remember(RegisteredAccount account) async {
    await _sessionStore.saveAccount(SavedAccount.fromAccount(account));
    final credential = AuthRegistrationService.instance.currentRefreshToken;
    if (credential != null && credential.isNotEmpty) {
      await _sessionStore.writeCredential(account.id, credential);
    }
  }

  void _ensureAuthListener() {
    if (_authSubscription != null ||
        !AuthRegistrationService.instance.usesSupabase) {
      return;
    }
    _authSubscription = AgrisellSupabase.client.auth.onAuthStateChange.listen((
      state,
    ) {
      final session = state.session;
      final credential = session?.refreshToken;
      if (session == null || credential == null || credential.isEmpty) return;
      unawaited(_refreshSavedCredential(session.user.id, credential));
    });
  }

  Future<void> _refreshSavedCredential(
    String accountId,
    String credential,
  ) async {
    try {
      if (await _sessionStore.containsAccount(accountId)) {
        await _sessionStore.writeCredential(accountId, credential);
      }
    } on Object {
      // Keep the active session usable if secure storage is temporarily locked.
    }
  }

  Future<void> _persistActiveAccount(String accountId) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_accountIdKey, accountId);
  }

  Future<void> _clearPersistedAccount() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_accountIdKey);
  }
}
