import 'dart:async';

import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/presentation/auth_navigation_observer.dart';
import 'package:agresell_app/features/auth/presentation/auth_navigation_scope.dart';
import 'package:agresell_app/features/auth/presentation/screens/login_screen.dart';
import 'package:agresell_app/features/auth/presentation/widgets/otp_verification_screen.dart';
import 'package:agresell_app/features/rider/profile/presentation/screens/rider_sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/auth_account_fixture.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthSessionService.instance.clearMemoryForTesting();
    AuthRegistrationService.instance.clearForTesting();
  });
  tearDown(() {
    AuthSessionService.instance.clearMemoryForTesting();
    AuthRegistrationService.instance.clearForTesting();
  });

  testWidgets('first rider Continue survives session loss and opens OTP', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1000);
    addTearDown(tester.view.reset);
    final account = await registerTestAccount();
    await tester.runAsync(
      () => AuthSessionService.instance.start(account, rememberMe: false),
    );
    final key = GlobalKey<NavigatorState>();
    final observer = AuthNavigationObserver();
    final response = Completer<bool>();
    var requests = 0;
    AuthRegistrationService.instance.setEmailStarterForTesting((_, _, _) {
      requests++;
      // Model the old app session being invalidated by signup/probing Auth.
      AuthSessionService.instance.clearMemoryForTesting();
      return response.future;
    });
    await tester.pumpWidget(_app(key, observer));
    key.currentState!.push(
      agrisellPageRoute<void>(builder: (_) => const RiderSignUpScreen()),
    );
    await tester.pumpAndSettle();
    final originalForm = tester.state(find.byType(RiderSignUpScreen));
    await tester.enterText(find.byType(EditableText).at(0), 'new@example.com');
    await tester.enterText(find.byType(EditableText).at(1), 'Password123!');
    await tester.enterText(find.byType(EditableText).at(2), 'Password123!');
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    final next = find.widgetWithText(FilledButton, 'Continue');
    await tester.ensureVisible(next);
    await tester.tap(next);
    // The pending request keeps the loading spinner animating.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(requests, 1);
    expect(tester.state(find.byType(RiderSignUpScreen)), same(originalForm));
    expect(find.byType(LoginScreen), findsNothing);
    expect(
      find.text('Private outgoing data', skipOffstage: false),
      findsNothing,
    );
    expect(key.currentState!.canPop(), isFalse);
    response.complete(true);
    await tester.pumpAndSettle();
    expect(find.byType(OtpVerificationScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
    await key.currentState!.maybePop();
    await tester.pumpAndSettle();
    expect(tester.state(find.byType(RiderSignUpScreen)), same(originalForm));
    expect(
      tester
          .widget<EditableText>(find.byType(EditableText).first)
          .controller
          .text,
      'new@example.com',
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final publicFlow in [false, true]) {
    testWidgets(
      'session loss clears dialogs and private history: $publicFlow',
      (tester) async {
        final account = await registerTestAccount();
        await tester.runAsync(
          () => AuthSessionService.instance.start(account, rememberMe: false),
        );
        final key = GlobalKey<NavigatorState>();
        final observer = AuthNavigationObserver();
        await tester.pumpWidget(_app(key, observer));
        if (publicFlow) {
          key.currentState!.push(
            agrisellMaterialPageRoute<void>(
              builder: (_) => const RiderSignUpScreen(),
            ),
          );
          await tester.pumpAndSettle();
        }
        unawaited(
          showDialog<void>(
            context: key.currentContext!,
            builder: (_) =>
                const AlertDialog(content: Text('Private modal data')),
          ),
        );
        await tester.pumpAndSettle();
        AuthSessionService.instance.clearMemoryForTesting();
        await tester.pumpAndSettle();
        expect(
          find.text('Private modal data', skipOffstage: false),
          findsNothing,
        );
        expect(
          find.text('Private outgoing data', skipOffstage: false),
          findsNothing,
        );
        expect(
          find.byType(LoginScreen),
          publicFlow ? findsNothing : findsOneWidget,
        );
        if (publicFlow) expect(find.byType(RiderSignUpScreen), findsOneWidget);
        expect(key.currentState!.canPop(), isFalse);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  for (final privatePage in [false, true]) {
    testWidgets(
      'session loss above signup preserves only public OTP: $privatePage',
      (tester) async {
        final account = await registerTestAccount();
        await tester.runAsync(
          () => AuthSessionService.instance.start(account, rememberMe: false),
        );
        final key = GlobalKey<NavigatorState>();
        final observer = AuthNavigationObserver();
        await tester.pumpWidget(_app(key, observer));
        key.currentState!.push(
          agrisellPageRoute<void>(builder: (_) => const RiderSignUpScreen()),
        );
        await tester.pumpAndSettle();
        key.currentState!.push(
          agrisellPageRoute<void>(
            builder: (_) => privatePage
                ? const Scaffold(body: Text('Another private page'))
                : OtpVerificationScreen(
                    destination: 'new@example.com',
                    onVerify: (_) async {},
                  ),
          ),
        );
        await tester.pumpAndSettle();
        AuthSessionService.instance.clearMemoryForTesting();
        await tester.pumpAndSettle();
        expect(
          find.text('Private outgoing data', skipOffstage: false),
          findsNothing,
        );
        expect(
          find.text('Another private page', skipOffstage: false),
          findsNothing,
        );
        expect(
          find.byType(LoginScreen),
          privatePage ? findsOneWidget : findsNothing,
        );
        if (!privatePage) {
          expect(find.byType(OtpVerificationScreen), findsOneWidget);
          await key.currentState!.maybePop();
          await tester.pumpAndSettle();
          expect(find.byType(RiderSignUpScreen), findsOneWidget);
        }
        expect(key.currentState!.canPop(), isFalse);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}

Widget _app(GlobalKey<NavigatorState> key, AuthNavigationObserver observer) =>
    MaterialApp(
      navigatorKey: key,
      navigatorObservers: [observer],
      builder: (_, child) => AuthNavigationScope(
        navigatorKey: key,
        observer: observer,
        child: child!,
      ),
      home: const Scaffold(body: Text('Private outgoing data')),
    );
