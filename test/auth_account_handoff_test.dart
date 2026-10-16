import 'dart:async';

import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/presentation/account_session_navigation.dart';
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

  test(
    'switching updates the remembered email to the selected account',
    () async {
      final first = await registerTestAccount(email: 'first@example.com');
      final second = await registerTestAccount(
        email: 'second@example.com',
        phoneNumber: '09222222222',
      );
      final session = AuthSessionService.instance;
      await session.start(first, rememberMe: true);
      await session.start(second, rememberMe: true);
      await session.switchTo(first.id);
      expect(await session.loadRememberedIdentifier(), first.email);
    },
  );

  test('slow order loading does not hold up successful sign-in', () async {
    final account = await registerTestAccount();
    final pendingOrders = Completer<void>();
    final session = AuthSessionService.forTesting(
      loadOrders: (_) => pendingOrders.future,
    );
    await session.start(account, rememberMe: false);
    expect(session.isAuthenticated, isTrue);
    expect(pendingOrders.isCompleted, isFalse);
    pendingOrders.complete();
    await Future<void>.delayed(Duration.zero);
    session.clearMemoryForTesting();
    session.dispose();
  });

  test(
    'failed order loading does not turn a valid sign-in into a failure',
    () async {
      final account = await registerTestAccount();
      final session = AuthSessionService.forTesting(
        loadOrders: (_) =>
            Future<void>.error(StateError('order service failed')),
      );
      await session.start(account, rememberMe: false);
      expect(session.isAuthenticated, isTrue);
      session.clearMemoryForTesting();
      session.dispose();
    },
  );

  testWidgets('session handoff preserves the selected login email', (
    tester,
  ) async {
    final outgoing = await registerTestAccount(email: 'outgoing@example.com');
    await tester.runAsync(
      () => AuthSessionService.instance.start(outgoing, rememberMe: true),
    );
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: key,
        builder: (_, child) =>
            AuthNavigationScope(navigatorKey: key, child: child!),
        home: const Scaffold(body: Text('Outgoing private content')),
      ),
    );
    key.currentState!.pushAndRemoveUntil(
      agrisellPageRoute<void>(
        settings: const RouteSettings(name: 'auth.login'),
        builder: (_) =>
            const LoginScreen(initialIdentifier: 'selected@example.com'),
      ),
      (_) => false,
    );
    await tester.pumpAndSettle();
    AuthSessionService.instance.clearMemoryForTesting();
    await tester.pumpAndSettle();
    final fields = tester.widgetList<TextField>(find.byType(TextField));
    expect(fields.first.controller!.text, 'selected@example.com');
    expect(find.text('Outgoing private content'), findsNothing);
    expect(key.currentState!.canPop(), isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'logout uses the active email and prevents private back navigation',
    (tester) async {
      final active = await registerTestAccount(email: 'active@example.com');
      await tester.runAsync(
        () => AuthSessionService.instance.start(active, rememberMe: true),
      );
      final key = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: key,
          builder: (_, child) =>
              AuthNavigationScope(navigatorKey: key, child: child!),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => AccountSessionNavigation.logout(context),
                child: const Text('Log out'),
              ),
            ),
          ),
        ),
      );
      await tester.runAsync(() async {
        await tester.tap(find.text('Log out'));
      });
      await tester.pumpAndSettle();
      expect(find.text('Are you sure you want to log out?'), findsOneWidget);
      expect(AuthSessionService.instance.isAuthenticated, isTrue);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsNothing);
      expect(AuthSessionService.instance.currentAccount?.id, active.id);
      expect(AuthSessionService.instance.isAuthenticated, isTrue);
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsNothing);
      expect(AuthSessionService.instance.isAuthenticated, isTrue);
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      await key.currentState!.maybePop();
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsNothing);
      expect(AuthSessionService.instance.isAuthenticated, isTrue);
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await tester.tap(find.widgetWithText(FilledButton, 'Log out'));
      });
      await tester.pump();
      await tester.runAsync(() async {
        await Future<void>.delayed(Duration.zero);
      });
      await tester.pumpAndSettle();
      final field = tester.widget<TextField>(find.byType(TextField).first);
      expect(field.controller!.text, active.email);
      expect(AuthSessionService.instance.isAuthenticated, isFalse);
      expect(key.currentState!.canPop(), isFalse);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
