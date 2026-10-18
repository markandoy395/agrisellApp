import 'dart:convert';

import 'package:agresell_app/core/updates/app_update_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  Map<String, Object> manifest({int build = 3, String? apk}) => {
    'version': '1.0.2',
    'buildNumber': build,
    'apkUrl': apk ?? 'downloads/agrisell-1.0.2-3.apk',
    'notes': 'Bug fixes',
  };

  Future<Object?> check(Object body, {int installed = 2, int status = 200}) {
    final client = MockClient((request) async {
      expect(request.url.path, '/get-agrisell/release.json');
      expect(request.url.queryParameters['check'], isNotEmpty);
      expect(request.headers.containsKey('authorization'), isFalse);
      return http.Response(jsonEncode(body), status);
    });
    addTearDown(client.close);
    return AppUpdateService(
      client: client,
      installedBuild: () async => installed,
    ).check();
  }

  test('newer build resolves APK under the hosted website directory', () async {
    final release = await AppUpdateService(
      client: MockClient(
        (_) async => http.Response(jsonEncode(manifest()), 200),
      ),
      installedBuild: () async => 2,
    ).check();
    expect(release?.version, '1.0.2');
    expect(
      release?.apkUri.toString(),
      'https://markandoy395.github.io/get-agrisell/downloads/agrisell-1.0.2-3.apk',
    );
  });

  test('same and older builds never prompt', () async {
    expect(await check(manifest(build: 2)), isNull);
    expect(await check(manifest(build: 1)), isNull);
  });

  test('bad responses and malformed metadata fail quietly', () async {
    expect(await check(manifest(), status: 404), isNull);
    expect(await check('<html>not a release</html>'), isNull);
    expect(await check({'version': '1.0.2', 'buildNumber': '3'}), isNull);
    expect(await check({...manifest(), 'notes': 123}), isNull);
  });

  test('rejects untrusted download origins and non-APK links', () async {
    for (final apk in [
      'https://untrusted.example/app.apk',
      'http://markandoy395.github.io/get-agrisell/app.apk',
      'javascript:alert(1)',
      'downloads/app.html',
      'https://user:password@markandoy395.github.io/app.apk',
    ]) {
      expect(await check(manifest(apk: apk)), isNull, reason: apk);
    }
  });

  test('network failure does not escape the optional check', () async {
    final client = MockClient(
      (_) async => throw http.ClientException('offline'),
    );
    addTearDown(client.close);
    expect(
      await AppUpdateService(
        client: client,
        installedBuild: () async => 2,
      ).check(),
      isNull,
    );
  });
}
