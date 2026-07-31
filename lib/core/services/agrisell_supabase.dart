import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
  static String _resolvedPublishableKey = publishableKey;

  static bool get isConfigured => _resolvedPublishableKey.trim().isNotEmpty;
  static bool get isInitialized => _isInitialized;

  static SupabaseClient get client {
    if (!_isInitialized) {
      throw StateError('Supabase has not been initialized.');
    }
    return Supabase.instance.client;
  }

  static Future<bool> initialize() async {
    if (_isInitialized) return true;
    if (!isConfigured) {
      final localConfig = await _loadLocalConfig();
      _resolvedPublishableKey = _stringValue(
        localConfig['SUPABASE_PUBLISHABLE_KEY'],
      );
    }
    if (!isConfigured) return false;
    await Supabase.initialize(
      url: projectUrl,
      publishableKey: _resolvedPublishableKey,
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

  static Future<Map<String, Object?>> _loadLocalConfig() async {
    try {
      final contents = await rootBundle.loadString('supabase.local.json');
      final decoded = jsonDecode(contents);
      if (decoded is Map<String, Object?>) return decoded;
    } on FlutterError {
      return const {};
    } on FormatException {
      return const {};
    }
    return const {};
  }

  static String _stringValue(Object? value) => value is String ? value : '';
}
