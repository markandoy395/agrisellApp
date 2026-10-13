import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/secure_supabase_local_storage.dart';
import 'package:agresell_app/core/services/rate_limited_supabase_http_client.dart';

/// Central Supabase bootstrap. Build-time values can override the ignored
/// local asset used by a normal development run.
class AgrisellSupabase {
  const AgrisellSupabase._();

  static const _localConfigAsset = 'assets/config/supabase.local.json';
  static const _definedProjectUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://aaxmohxwzmbjfgfkkejm.supabase.co',
  );
  static const _definedPublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static bool _isInitialized = false;
  static String _projectUrl = _definedProjectUrl;
  static String _publishableKey = _definedPublishableKey;

  static String get projectUrl => _projectUrl;
  static String get publishableKey => _publishableKey;
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
    final configuration = await _resolveConfiguration();
    if (configuration == null) return false;
    _projectUrl = configuration.projectUrl;
    _publishableKey = configuration.publishableKey;
    await Supabase.initialize(
      url: configuration.projectUrl,
      publishableKey: configuration.publishableKey,
      httpClient: const bool.fromEnvironment('SUPABASE_RATE_LIMIT_GATEWAY')
          ? RateLimitedSupabaseHttpClient(projectUrl: configuration.projectUrl)
          : null,
      authOptions: FlutterAuthClientOptions(
        localStorage: SecureSupabaseLocalStorage(
          legacySessionKey:
              'sb-${Uri.parse(configuration.projectUrl).host.split('.').first}-auth-token',
        ),
      ),
    );
    _isInitialized = true;
    return true;
  }

  static Future<_SupabaseConfiguration?> _resolveConfiguration() async {
    if (_definedPublishableKey.trim().isNotEmpty) {
      return const _SupabaseConfiguration(
        projectUrl: _definedProjectUrl,
        publishableKey: _definedPublishableKey,
      );
    }
    try {
      final decoded = jsonDecode(
        await rootBundle.loadString(_localConfigAsset),
      );
      if (decoded is! Map<String, dynamic>) return null;
      final configuredUrl = decoded['SUPABASE_URL']?.toString().trim() ?? '';
      final configuredKey =
          decoded['SUPABASE_PUBLISHABLE_KEY']?.toString().trim() ?? '';
      if (configuredKey.isEmpty) return null;
      return _SupabaseConfiguration(
        projectUrl: configuredUrl.isEmpty ? _definedProjectUrl : configuredUrl,
        publishableKey: configuredKey,
      );
    } catch (_) {
      return null;
    }
  }
}

class _SupabaseConfiguration {
  const _SupabaseConfiguration({
    required this.projectUrl,
    required this.publishableKey,
  });

  final String projectUrl;
  final String publishableKey;
}
