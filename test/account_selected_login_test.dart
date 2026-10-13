import 'package:agresell_app/features/auth/data/account_session_store.dart';
import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/domain/saved_account.dart';
import 'package:agresell_app/features/auth/presentation/auth_navigation_scope.dart';
import 'package:agresell_app/features/auth/presentation/screens/account_switcher_screen.dart';
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

  testWidgets(
    'unavailable saved session keeps the clicked email for password login',
    (tester) async {
      final outgoing = await registerTestAccount(email: 'outgoing@example.com');
      await tester.runAsync(() async {
        await AuthSessionService.instance.start(outgoing, rememberMe: true);
        await AccountSessionStore().saveAccount(
          const SavedAccount(
            id: 'unavailable',
            firstName: 'Selected',
            lastName: 'Account',
            email: 'clicked@example.com',
            role: 'buyer',
          ),
        );
      });
      final key = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: key,
          builder: (_, child) =>
              AuthNavigationScope(navigatorKey: key, child: child!),
          home: const AccountSwitcherScreen(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await tester.tap(find.text('clicked@example.com'));
      });
      await tester.pump();
      await tester.runAsync(() async {
        await Future<void>.delayed(Duration.zero);
      });
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      final field = tester.widget<TextField>(find.byType(TextField).first);
      expect(field.controller!.text, 'clicked@example.com');
      expect(key.currentState!.canPop(), isFalse);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
