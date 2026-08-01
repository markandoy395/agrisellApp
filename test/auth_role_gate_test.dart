import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/auth/presentation/auth_role_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/auth_account_fixture.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AuthRegistrationService.instance.clearForTesting();
    AuthSessionService.instance.clearMemoryForTesting();
    await registerTestAccount();
  });

  tearDown(() {
    AuthRegistrationService.instance.clearForTesting();
    AuthSessionService.instance.clearMemoryForTesting();
  });

  testWidgets('role gate blocks a dashboard outside the active role', (
    tester,
  ) async {
    final farmer = AuthRegistrationService.instance.registeredAccounts.first;
    await tester.runAsync(
      () => AuthSessionService.instance.start(farmer, rememberMe: false),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: AuthRoleGate(
          requiredRole: AuthRole.buyer,
          child: Text('Buyer-only content'),
        ),
      ),
    );

    expect(find.text('Buyer-only content'), findsNothing);
    expect(find.text('Account access restricted'), findsOneWidget);
  });

  testWidgets('role gate redirects an authenticated user to an allowed home', (
    tester,
  ) async {
    final farmer = AuthRegistrationService.instance.registeredAccounts.first;
    await tester.runAsync(
      () => AuthSessionService.instance.start(farmer, rememberMe: false),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AuthRoleGate(
          requiredRole: AuthRole.buyer,
          redirectFor: (_) =>
              const Scaffold(body: Center(child: Text('Farmer dashboard'))),
          child: const Text('Buyer-only content'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Buyer-only content'), findsNothing);
    expect(find.text('Farmer dashboard'), findsOneWidget);
  });
}
