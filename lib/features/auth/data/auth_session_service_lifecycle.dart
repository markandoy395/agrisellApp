part of 'auth_session_service.dart';

extension AuthSessionServiceLifecycle on AuthSessionService {
  Future<AuthSessionRestoreResult> restore() async {
    final accountId = await _persistedAccountId();
    if (accountId == null) {
      await _clearRuntime(signOut: true);
      return const AuthSessionRestoreResult.noSession();
    }
    try {
      RegisteredAccount? account;
      if (AuthRegistrationService.instance.usesSupabase) {
        account = await AuthRegistrationService.instance.loadCurrentAccount();
        if (account?.id != accountId) {
          final credential = await _sessionStore.readCredential(accountId);
          account = credential == null
              ? null
              : await AuthRegistrationService.instance.restoreSavedSession(
                  credential,
                );
        }
      } else {
        account = AuthRegistrationService.instance.accountById(accountId);
      }
      if (account == null || account.id != accountId) {
        await _clearRuntime(signOut: true);
        await _clearPersistedAccount();
        return const AuthSessionRestoreResult.expired();
      }
      await _activate(account);
      await _remember(account);
      _currentAccountRemembered = true;
      return AuthSessionRestoreResult(account: account, wasExpired: false);
    } on Object {
      await _clearRuntime(signOut: true);
      await _clearPersistedAccount();
      return const AuthSessionRestoreResult.expired();
    }
  }

  Future<void> removeSavedAccount(String accountId) async {
    if (accountId == _currentAccountId) {
      throw const SavedAccountSessionException(
        'Log out to remove the active account from this device.',
      );
    }
    await _sessionStore.removeAccount(
      accountId,
      removeCredential: AuthRegistrationService.instance.usesSupabase,
    );
  }

  Future<void> clear({bool forgetAccount = true}) async {
    final accountId = _currentAccountId;
    final shouldForgetAccount = forgetAccount && _currentAccountRemembered;
    await BasketController.instance.flush();
    await _clearRuntime(signOut: true);
    await _clearPersistedAccount();
    if (shouldForgetAccount && accountId != null) {
      await _sessionStore.removeAccount(
        accountId,
        removeCredential: AuthRegistrationService.instance.usesSupabase,
      );
    }
  }

  Future<String?> _persistedAccountId() async {
    try {
      final preferences = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 1),
      );
      return preferences.getString(AuthSessionService._accountIdKey);
    } on Object {
      return null;
    }
  }

  Future<void> _clearRuntime({required bool signOut}) async {
    _currentAccountId = null;
    _currentAccountRemembered = false;
    _clearAccountState();
    _notifySessionChanged();
    if (signOut && AuthRegistrationService.instance.usesSupabase) {
      await AuthRegistrationService.instance.signOut();
    }
  }

  void _clearAccountState({bool clearSnapshot = true}) {
    if (clearSnapshot) unawaited(HomeProductSnapshotCache.instance.clear());
    BasketController.instance.unload();
    FarmerFollowController.instance.unload();
    OrderController.instance.unload();
    RiderRegistrationService.instance.clearCurrentProfile();
  }

  void clearMemoryForTesting() {
    _currentAccountId = null;
    _currentAccountRemembered = false;
    _clearAccountState(clearSnapshot: false);
    _notifySessionChanged();
  }
}
