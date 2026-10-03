import 'dart:io';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/core/services/authenticated_storage_image.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/presentation/auth_page_gate.dart';
import 'package:agresell_app/features/auth/presentation/auth_navigation_scope.dart';
import 'package:agresell_app/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/auth_account_fixture.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthRegistrationService.instance.clearForTesting();
    AuthSessionService.instance.clearMemoryForTesting();
  });

  tearDown(() {
    AuthSessionService.instance.clearMemoryForTesting();
    AuthRegistrationService.instance.clearForTesting();
  });

  testWidgets('signed-out private pages never mount and redirect to login', (
    tester,
  ) async {
    var mounted = false;
    await tester.pumpWidget(
      MaterialApp(
        home: AuthPageGate(child: _PrivatePage(onMount: () => mounted = true)),
      ),
    );
    expect(mounted, isFalse);
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(mounted, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('both direct route factories protect unknown private pages', (
    tester,
  ) async {
    for (final material in [false, true]) {
      final key = GlobalKey<NavigatorState>();
      var mounted = false;
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: key,
          home: const Scaffold(body: Text('Public entry')),
        ),
      );
      key.currentState!.push(
        material
            ? agrisellMaterialPageRoute<void>(
                builder: (_) => _PrivatePage(onMount: () => mounted = true),
              )
            : agrisellPageRoute<void>(
                builder: (_) => _PrivatePage(onMount: () => mounted = true),
              ),
      );
      await tester.pump();
      await tester.pumpAndSettle();
      expect(mounted, isFalse);
      expect(find.byType(LoginScreen), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('losing the session removes already mounted private content', (
    tester,
  ) async {
    final account = await registerTestAccount();
    await tester.runAsync(
      () => AuthSessionService.instance.start(account, rememberMe: false),
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: AuthPageGate(child: Scaffold(body: Text('Private data'))),
      ),
    );
    expect(find.text('Private data'), findsOneWidget);
    AuthSessionService.instance.clearMemoryForTesting();
    await tester.pump();
    expect(find.text('Private data'), findsNothing);
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test(
    'project storage URLs use bearer authentication without signed tokens',
    () {
      final root = AgrisellSupabase.projectUrl;
      expect(
        authenticatedStorageUrl(
          '$root/storage/v1/object/public/farmer-media/a.jpg',
        ),
        '$root/storage/v1/object/authenticated/farmer-media/a.jpg',
      );
      expect(
        authenticatedStorageUrl(
          '$root/storage/v1/object/sign/rider-documents/a.jpg?token=secret',
        ),
        '$root/storage/v1/object/authenticated/rider-documents/a.jpg',
      );
      expect(storageImageHeaders('https://example.com/a.jpg'), isNull);
      expect(
        authenticatedStorageUrl('https://example.com/a.jpg?token=external'),
        'https://example.com/a.jpg?token=external',
      );
    },
  );

  test('feature routes cannot bypass the guarded factories', () {
    final files = Directory('lib/features')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    for (final file in files) {
      if (file.path.endsWith('auth_page_gate.dart') ||
          file.path.endsWith('auth_navigation_scope.dart'))
        continue;
      expect(
        file.readAsStringSync(),
        isNot(
          matches(
            r'\b(MaterialPageRoute|PageRouteBuilder|CupertinoPageRoute)\s*(<[^>]+>)?\s*\(',
          ),
        ),
        reason: file.path,
      );
    }
  });

  testWidgets('session loss clears private dialogs and the navigation stack', (
    tester,
  ) async {
    final account = await registerTestAccount();
    await tester.runAsync(
      () => AuthSessionService.instance.start(account, rememberMe: false),
    );
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: key,
        builder: (_, child) =>
            AuthNavigationScope(navigatorKey: key, child: child!),
        home: const Scaffold(body: Text('Dashboard data')),
      ),
    );
    showDialog<void>(
      context: key.currentContext!,
      builder: (_) => const AlertDialog(content: Text('Private modal data')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Private modal data'), findsOneWidget);
    AuthSessionService.instance.clearMemoryForTesting();
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Private modal data'), findsNothing);
    expect(find.text('Dashboard data'), findsNothing);
    expect(key.currentState!.canPop(), isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

class _PrivatePage extends StatefulWidget {
  const _PrivatePage({required this.onMount});
  final VoidCallback onMount;
  @override
  State<_PrivatePage> createState() => _PrivatePageState();
}

class _PrivatePageState extends State<_PrivatePage> {
  @override
  void initState() {
    super.initState();
    widget.onMount();
  }

  @override
  Widget build(BuildContext context) => const Text('Private data');
}
