part of 'auth_session_service.dart';

extension AuthSessionServiceSwitching on AuthSessionService {
  Future<RegisteredAccount> _switchToAccount(String accountId) async {
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

    await preserveCurrentAccountForSwitch();

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
    await _persistRememberedIdentifier(account.email);
    _currentAccountRemembered = true;
    return account;
  }
}
