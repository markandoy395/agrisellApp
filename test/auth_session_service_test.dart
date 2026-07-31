import 'package:agresell_app/features/auth/data/authRegistrationService.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/auth_account_fixture.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AuthRegistrationService.instance.clearForTesting();
    AuthSessionService.instance.clearMemoryForTesting();
    await registerTestAccount();
  });

  tearDown(() {
    AuthRegistrationService.instance.clearForTesting();
    AuthSessionService.instance.clearMemoryForTesting();
  });

  test(
    'remembered sessions restore the trusted account record, not a role value',
    () async {
      final account = AuthRegistrationService.instance.registeredAccounts.first;
      await AuthSessionService.instance.start(account, rememberMe: true);
      AuthSessionService.instance.clearMemoryForTesting();

      final restored = await AuthSessionService.instance.restore();

      expect(restored.account?.id, account.id);
      expect(restored.account?.role, 'farmer');
      expect(restored.wasExpired, isFalse);
      expect(AuthSessionService.instance.currentAccount?.id, account.id);
    },
  );

  test('logout clears the persisted session identifier', () async {
    final account = AuthRegistrationService.instance.registeredAccounts.first;
    await AuthSessionService.instance.start(account, rememberMe: true);
    await AuthSessionService.instance.clear();
    AuthSessionService.instance.clearMemoryForTesting();

    expect((await AuthSessionService.instance.restore()).account, isNull);
  });

  test(
    'an unchecked login clears a remembered session after app restart',
    () async {
      final account = AuthRegistrationService.instance.registeredAccounts.first;
      await AuthSessionService.instance.start(account, rememberMe: true);
      AuthSessionService.instance.clearMemoryForTesting();

      await AuthSessionService.instance.start(account, rememberMe: false);
      AuthSessionService.instance.clearMemoryForTesting();

      final restored = await AuthSessionService.instance.restore();

      expect(restored.account, isNull);
      expect(restored.wasExpired, isFalse);
    },
  );

  test('missing remembered account reports an expired session', () async {
    SharedPreferences.setMockInitialValues({
      'auth.session.account-id': 'deleted-account',
    });

    final restored = await AuthSessionService.instance.restore();

    expect(restored.account, isNull);
    expect(restored.wasExpired, isTrue);
  });
}
