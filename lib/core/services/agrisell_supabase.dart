import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/secure_supabase_local_storage.dart';

/// Central Supabase bootstrap. Credentials are supplied at build/run time and
/// are never stored in source control.
class AgrisellSupabase {
  const AgrisellSupabase._();

  static const projectUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://aaxmohxwzmbjfgfkkejm.supabase.co',
  );
  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static bool _isInitialized = false;

  static bool get isConfigured => publishableKey.trim().isNotEmpty;
  static bool get isInitialized => _isInitialized;

  static SupabaseClient get client {
    if (!_isInitialized) {
      throw StateError('Supabase has not been initialized.');
    }
    return Supabase.instance.client;
  }

  static Future<bool> initialize() async {
    if (_isInitialized) return true;
    if (!isConfigured) return false;
    await Supabase.initialize(
      url: projectUrl,
      publishableKey: publishableKey,
      authOptions: FlutterAuthClientOptions(
        localStorage: SecureSupabaseLocalStorage(
          legacySessionKey:
              'sb-${Uri.parse(projectUrl).host.split('.').first}-auth-token',
        ),
      ),
    );
    _isInitialized = true;
    return true;
  }
}
