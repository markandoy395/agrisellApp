import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/auth/presentation/screens/login_screen.dart';
import 'package:agresell_app/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpRoleSelection(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(430, 932));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AgrisellTheme.light,
      home: const RoleSelectionScreen.signUp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> pumpLogin(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(430, 932));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AgrisellTheme.light,
      home: const LoginScreen(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> enterValidSignUpDetails(
  WidgetTester tester, {
  required String email,
}) async {
  await _enterText(tester, 'Email', email);
  await _enterText(tester, 'Password', 'Password123!');
  await _enterText(tester, 'Confirm Password', 'Password123!');
  await tester.ensureVisible(find.widgetWithText(FilledButton, 'Continue'));
  await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
  await tester.pumpAndSettle();

  await _enterText(tester, 'First Name', 'Ana');
  await _enterText(tester, 'Last Name', 'Reyes');
  await _enterText(tester, 'Name Extension (Optional)', 'Jr.');
  await _enterText(tester, 'Phone Number (09XXXXXXXXX)', '09171234567');
  await _enterText(tester, 'House / street / purok', 'Purok 5');
  await _enterText(tester, 'Province (select or type)', 'Surigao del Sur');
  await _enterText(tester, 'City or municipality (select or type)', 'Lianga');
  await _enterText(tester, 'Barangay (select or type)', 'Poblacion');
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();

  final birthDate = find.widgetWithText(TextField, 'Date of Birth');
  await tester.ensureVisible(birthDate);
  await tester.pumpAndSettle();
  await tester.tap(birthDate);
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();

  final genderField = find.byType(DropdownButtonFormField<String>);
  await tester.ensureVisible(genderField);
  await tester.tap(genderField);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Female').last);
  await tester.pumpAndSettle();

  await tester.ensureVisible(find.byType(Checkbox));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(Checkbox));
}

Future<void> _enterText(WidgetTester tester, String hint, String value) async {
  final field = find.widgetWithText(TextField, hint);
  await tester.ensureVisible(field);
  await tester.pumpAndSettle();
  await tester.enterText(field, value);
}
