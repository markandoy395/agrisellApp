import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import 'app_release.dart';

class AppUpdateService {
  AppUpdateService({
    http.Client? client,
    Future<int> Function()? installedBuild,
  }) : _client = client,
       _installedBuild = installedBuild ?? _readInstalledBuild;

  static const websiteUrl = String.fromEnvironment(
    'AGRISELL_DOWNLOAD_WEBSITE',
    defaultValue: 'https://markandoy395.github.io/get-agrisell/',
  );
  final http.Client? _client;
  final Future<int> Function() _installedBuild;

  static Future<int> _readInstalledBuild() async {
    final info = await PackageInfo.fromPlatform();
    return int.parse(info.buildNumber);
  }

  Future<AppRelease?> check() async {
    final client = _client ?? http.Client();
    try {
      final base = Uri.parse(websiteUrl);
      if (base.scheme != 'https' || base.host.isEmpty) return null;
      final manifest = base.resolve('release.json');
      final uri = manifest.replace(
        queryParameters: {
          'check': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );
      final response = await client
          .get(uri)
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200 || response.bodyBytes.length > 16384) {
        return null;
      }
      final release = AppRelease.parse(jsonDecode(response.body), manifest);
      if (release == null) return null;
      final installed = await _installedBuild().timeout(
        const Duration(seconds: 3),
      );
      return release.buildNumber > installed ? release : null;
    } catch (_) {
      // Optional public release metadata must never interrupt normal app use.
      return null;
    } finally {
      if (_client == null) client.close();
    }
  }
}
