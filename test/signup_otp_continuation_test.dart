import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/auth/presentation/auth_navigation_scope.dart';
import 'package:agresell_app/features/auth/presentation/auth_navigation_observer.dart';
import 'package:agresell_app/features/auth/presentation/screens/login_screen.dart';
import 'package:agresell_app/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:agresell_app/features/auth/presentation/widgets/otp_verification_screen.dart';
import 'package:agresell_app/features/farmer/registration/presentation/screens/farmer_sign_up_screen.dart';
import 'package:agresell_app/features/rider/profile/presentation/screens/rider_sign_up_screen.dart';

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
  for (final role in AuthRole.values) {
    testWidgets('${role.name} OTP continues to step two once and stays there', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(430, 1000);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final response = Completer<RegisteredAccount>();
      var requests = 0;
      AuthRegistrationService.instance.setEmailStarterForTesting((
        _,
        _,
        actualRole,
      ) async {
        expect(actualRole, role);
        return true;
      });
      AuthRegistrationService.instance.setEmailVerifierForTesting((
        email,
        code,
      ) {
        requests++;
        expect(code, '123456');
        return response.future;
      });
      final key = GlobalKey<NavigatorState>();
      final observer = AuthNavigationObserver();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: key,
          navigatorObservers: [observer],
          theme: AgrisellTheme.light,
          builder: (_, child) => AuthNavigationScope(
            navigatorKey: key,
            observer: observer,
            child: child!,
          ),
          home: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();
      key.currentState!.push(
        agrisellPageRoute<void>(
          builder: (_) => switch (role) {
            AuthRole.buyer => const SignUpScreen(role: AuthRole.buyer),
            AuthRole.farmer => const FarmerSignUpScreen(),
            AuthRole.rider => const RiderSignUpScreen(),
          },
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(EditableText).at(0),
        '${role.name}@example.com',
      );
      await tester.enterText(find.byType(EditableText).at(1), 'Password123!');
      await tester.enterText(find.byType(EditableText).at(2), 'Password123!');
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      final next = find.widgetWithText(FilledButton, 'Continue');
      await tester.ensureVisible(next);
      await tester.tap(next);
      await tester.pumpAndSettle();
      expect(find.byType(OtpVerificationScreen), findsOneWidget);
      await tester.enterText(find.byType(TextField), '123456');
      final submit = tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Verify'))
          .onPressed!;
      submit();
      submit(); // Simulates callbacks dispatched before a disabled-button rebuild.
      await tester.pump();
      response.complete(
        RegisteredAccount(
          id: 'pending-${role.name}',
          firstName: '',
          lastName: '',
          email: '${role.name}@example.com',
          passwordHash: '',
          passwordSalt: '',
          role: role.value,
          accountStatus: 'pending',
          profilePending: true,
        ),
      );
      await tester.pumpAndSettle();
      expect(requests, 1);
      expect(find.text('Personal information'), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(OtpVerificationScreen), findsNothing);
      expect(AuthSessionService.instance.isAuthenticated, isFalse);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('Personal information'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
