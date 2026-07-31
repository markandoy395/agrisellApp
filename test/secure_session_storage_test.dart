import 'package:agresell_app/core/services/secure_supabase_local_storage.dart';
import 'package:agresell_app/features/auth/data/account_session_store.dart';
import 'package:agresell_app/features/auth/domain/saved_account.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('account credentials stay outside non-sensitive preferences', () async {
    final store = AccountSessionStore();
    const account = SavedAccount(
      id: 'account-1',
      firstName: 'Saved',
      lastName: 'Buyer',
      email: 'saved@example.com',
      role: 'buyer',
    );

    await store.saveAccount(account);
    await store.writeCredential(account.id, 'private-refresh-token');

    expect(await store.readCredential(account.id), 'private-refresh-token');
    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getString('auth.saved-accounts.v1'),
      isNot(contains('private-refresh-token')),
    );
  });

  test(
    'Supabase session migrates from preferences into secure storage',
    () async {
      const legacyKey = 'legacy-supabase-session';
      SharedPreferences.setMockInitialValues({
        legacyKey: '{"refresh_token":"legacy-secret"}',
      });
      final storage = SecureSupabaseLocalStorage(legacySessionKey: legacyKey);

      await storage.initialize();

      expect(await storage.accessToken(), '{"refresh_token":"legacy-secret"}');
      expect(
        (await SharedPreferences.getInstance()).containsKey(legacyKey),
        isFalse,
      );
      await storage.removePersistedSession();
      expect(await storage.hasAccessToken(), isFalse);
    },
  );
}
