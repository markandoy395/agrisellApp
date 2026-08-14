import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/presentation/screens/login_screen.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_checkbox.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_text_field.dart';

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

  testWidgets('remember me restores only the identifier after logout', (
    tester,
  ) async {
    final account = await registerTestAccount(email: 'buyer@example.com');
    await AuthSessionService.instance.start(account, rememberMe: true);
    await AuthSessionService.instance.clear();

    await tester.pumpWidget(
      MaterialApp(theme: AgrisellTheme.light, home: const LoginScreen()),
    );
    await tester.pumpAndSettle();

    final fields = tester.widgetList<AuthTextField>(find.byType(AuthTextField));
    final identifier = fields.first.controller;
    final password = fields.elementAt(1).controller;
    final rememberMe = tester.widget<AuthCheckbox>(find.byType(AuthCheckbox));

    expect(identifier?.text, account.email);
    expect(password?.text, isEmpty);
    expect(rememberMe.value, isTrue);
  });
}
