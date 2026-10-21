import 'dart:convert';

import 'package:agresell_app/core/updates/app_release.dart';
import 'package:agresell_app/core/updates/app_update_dialog.dart';
import 'package:agresell_app/core/updates/app_update_observer.dart';
import 'package:agresell_app/core/updates/app_update_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('startup replacement offers an update, Later dismisses once', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    var requests = 0;
    final client = MockClient((_) async {
      requests++;
      return http.Response(
        jsonEncode({
          'version': '1.0.2',
          'buildNumber': 3,
          'apkUrl': 'downloads/agrisell-1.0.2-3.apk',
          'notes': 'Faster checkout',
        }),
        200,
      );
    });
    addTearDown(client.close);
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        navigatorObservers: [
          AppUpdateObserver(
            service: AppUpdateService(
              client: client,
              installedBuild: () async => 2,
            ),
          ),
        ],
        home: const Scaffold(body: Text('Splash')),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(requests, 0, reason: 'Do not prompt over the splash screen.');
    navigatorKey.currentState!.pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Home')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Update available'), findsOneWidget);
    expect(find.text('Faster checkout'), findsOneWidget);
    expect(find.text('Update now'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(BottomSheet), findsOneWidget);
    final card = tester.getRect(find.byKey(const ValueKey('app-update-card')));
    final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    expect(card.left, greaterThan(0));
    expect(card.right, lessThan(screen.width));
    expect(card.bottom, closeTo(screen.height - 12, 1));
    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();
    expect(find.text('Update available'), findsNothing);
    navigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Next page')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(minutes: 6));
    expect(requests, 1, reason: 'Do not repeatedly prompt during a launch.');
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('failed download opening shows retry text and allows dismissal', (
    tester,
  ) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/url_launcher'),
      (call) async {
        expect(call.method, 'launch');
        expect(call.arguments['url'], 'https://markandoy395.github.io/app.apk');
        return false;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/url_launcher'),
        null,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () => AppUpdateDialog.show(
                  context,
                  AppRelease(
                    version: '1.0.2',
                    buildNumber: 3,
                    apkUri: Uri.parse('https://markandoy395.github.io/app.apk'),
                    notes: '',
                  ),
                ),
                child: const Text('Show'),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
    // Simulate Android refusing to open the APK download.
    await tester.tap(find.text('Update now'));
    await tester.pumpAndSettle();
    expect(
      find.text('Could not open the download. Please try again.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();
    expect(find.text('Update available'), findsNothing);
  });

  testWidgets('update sheet scrolls on small screens with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => AppUpdateDialog.show(
                context,
                AppRelease(
                  version: '1.0.7',
                  buildNumber: 8,
                  apkUri: Uri.parse('https://markandoy395.github.io/app.apk'),
                  notes: List.filled(
                    30,
                    'Improved product publishing.',
                  ).join(' '),
                ),
              ),
              child: const Text('Show'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final card = tester.getRect(find.byKey(const ValueKey('app-update-card')));
    expect(card.left, 12);
    expect(card.right, 308);
    expect(card.bottom, 556);
    await tester.scrollUntilVisible(
      find.text('Later'),
      300,
      scrollable: find.descendant(
        of: find.byType(AppUpdateDialog),
        matching: find.byType(Scrollable),
      ),
      maxScrolls: 50,
    );
    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();
    expect(find.byType(AppUpdateDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
