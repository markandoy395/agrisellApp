import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/firebase_options.dart';

void main() {
  test(
    'native Android Firebase configuration matches FlutterFire options',
    () {
      final config =
          jsonDecode(
                File('android/app/google-services.json').readAsStringSync(),
              )
              as Map<String, dynamic>;
      final project = config['project_info'] as Map<String, dynamic>;
      final client = (config['client'] as List)
          .cast<Map<String, dynamic>>()
          .singleWhere(
            (entry) =>
                entry['client_info']['android_client_info']['package_name'] ==
                'com.agresell.agresell_app',
          );
      const options = DefaultFirebaseOptions.android;
      expect(project['project_id'], options.projectId);
      expect(project['project_number'], options.messagingSenderId);
      expect(project['storage_bucket'], options.storageBucket);
      expect(client['client_info']['mobilesdk_app_id'], options.appId);
      final keys = (client['api_key'] as List).cast<Map<String, dynamic>>();
      expect(
        keys.any((entry) => entry['current_key'] == options.apiKey),
        true,
        reason:
            'Android and Flutter must initialize the same Firebase project/key.',
      );
      expect(
        RegExp(r'^AIza[\w-]{35}$').hasMatch(options.apiKey),
        true,
        reason: 'Firebase API key must have a valid format, not a placeholder.',
      );
    },
    skip: !File('android/app/google-services.json').existsSync()
        ? 'Native Firebase config is ignored; provide the project config to run this check.'
        : false,
  );
}
