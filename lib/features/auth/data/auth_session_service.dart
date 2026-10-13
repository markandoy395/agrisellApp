import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/core/services/push_notification_service.dart';
import 'package:agresell_app/features/auth/data/account_session_store.dart';
import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/domain/auth_session_models.dart';
import 'package:agresell_app/features/auth/domain/saved_account.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/buyer/home/presentation/controllers/farmer_follow_controller.dart';
import 'package:agresell_app/features/rider/profile/data/rider_registration_service.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';

export 'package:agresell_app/features/auth/domain/auth_session_models.dart';

part 'auth_session_service_lifecycle.dart';
part 'auth_session_service_switching.dart';

class AuthSessionService extends ChangeNotifier {
  AuthSessionService._()
    : _loadOrders = OrderController.instance.loadForAccount;

  @visibleForTesting
  AuthSessionService.forTesting({
    required Future<void> Function(String) loadOrders,
  }) : _loadOrders = loadOrders;

  static final AuthSessionService instance = AuthSessionService._();
  static const _accountIdKey = 'auth.session.account-id';
  static const _rememberedIdentifierKey = 'auth.login.remembered-identifier';

  final AccountSessionStore _sessionStore = AccountSessionStore();
  final Future<void> Function(String) _loadOrders;
  StreamSubscription<AuthState>? _authSubscription;
  String? _currentAccountId;
  bool _currentAccountRemembered = false;

  void _notifySessionChanged() => notifyListeners();

  bool get isAuthenticated {
    final account = currentAccount;
    if (account == null) return false;
    if (!AuthRegistrationService.instance.usesSupabase) {
      return AuthRegistrationService.instance.localStoreEnabledForTesting;
    }
    final session = AgrisellSupabase.client.auth.currentSession;
    return session != null &&
        !session.isExpired &&
        !session.user.isAnonymous &&
        session.user.id == account.id;
  }

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
      await _clearRememberedIdentifier();
      return;
    }
    await _remember(account);
    await _persistActiveAccount(account.id);
    await _persistRememberedIdentifier(account.email);
    _currentAccountRemembered = true;
  }

  Future<String?> loadRememberedIdentifier() async {
    final preferences = await SharedPreferences.getInstance();
    final identifier = preferences.getString(_rememberedIdentifierKey)?.trim();
    return identifier == null || identifier.isEmpty ? null : identifier;
  }

  Future<void> preserveCurrentAccountForSwitch() async {
    final account = currentAccount;
    if (account == null) return;
    await _remember(account);
    _currentAccountRemembered = true;
  }

  Future<RegisteredAccount> switchTo(String accountId) =>
      _switchToAccount(accountId);

  Future<void> _activate(RegisteredAccount account) async {
    if (_currentAccountId != null && _currentAccountId != account.id) {
      _clearAccountState();
    }
    _currentAccountId = account.id;
    _currentAccountRemembered = false;
    _ensureAuthListener();
    notifyListeners();
    // Order history is optional for sign-in and must not block navigation.
    unawaited(_loadOrdersSafely(account.id));
    unawaited(PushNotificationService.instance.registerForUser(account.id));
  }

  Future<void> _loadOrdersSafely(String accountId) async {
    try {
      await _loadOrders(accountId);
    } on Object {
      if (kDebugMode) debugPrint('[auth] order_history failed (load_failed)');
    }
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
      if (state.event == AuthChangeEvent.signedOut ||
          (session != null && session.user.id != _currentAccountId)) {
        _currentAccountId = null;
        _currentAccountRemembered = false;
        _clearAccountState();
      }
      notifyListeners();
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

  Future<void> _persistRememberedIdentifier(String identifier) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_rememberedIdentifierKey, identifier.trim());
  }

  Future<void> _clearRememberedIdentifier() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_rememberedIdentifierKey);
  }
}
