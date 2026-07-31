import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SecureSupabaseLocalStorage extends LocalStorage {
  SecureSupabaseLocalStorage({required String legacySessionKey})
    : _secureStorage = const FlutterSecureStorage(),
      _legacyStorage = SharedPreferencesLocalStorage(
        persistSessionKey: legacySessionKey,
      );

  static const _sessionKey = 'auth.supabase.current-session.v1';

  final FlutterSecureStorage _secureStorage;
  final LocalStorage _legacyStorage;

  @override
  Future<void> initialize() async {
    await _legacyStorage.initialize();
    final secureSession = await _secureStorage.read(key: _sessionKey);
    final hasLegacySession = await _legacyStorage.hasAccessToken();
    if (secureSession == null && hasLegacySession) {
      final legacySession = await _legacyStorage.accessToken();
      if (legacySession != null) {
        await _secureStorage.write(key: _sessionKey, value: legacySession);
      }
    }
    if (hasLegacySession) await _legacyStorage.removePersistedSession();
  }

  @override
  Future<bool> hasAccessToken() async {
    return await _secureStorage.read(key: _sessionKey) != null;
  }

  @override
  Future<String?> accessToken() {
    return _secureStorage.read(key: _sessionKey);
  }

  @override
  Future<void> persistSession(String persistSessionString) {
    return _secureStorage.write(key: _sessionKey, value: persistSessionString);
  }

  @override
  Future<void> removePersistedSession() {
    return _secureStorage.delete(key: _sessionKey);
  }
}
