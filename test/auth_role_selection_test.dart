import 'package:agresell_app/core/theme/agrisellTheme.dart';
import 'package:agresell_app/features/auth/data/authRegistrationService.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/domain/signUpAccountData.dart';
import 'package:agresell_app/features/auth/presentation/screens/loginScreen.dart';
import 'package:agresell_app/features/farmer/registration/presentation/screens/farmer_sign_up_screen.dart';
import 'package:agresell_app/features/shared/widgets/navigation/custom_bottom_nav_bar.dart';
import 'package:agresell_app/features/rider/profile/presentation/screens/rider_sign_up_screen.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/screens/rider_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/auth_role_selection_helpers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthRegistrationService.instance.clearForTesting();
    AuthSessionService.instance.clearMemoryForTesting();
  });

  tearDown(() {
    AuthRegistrationService.instance.clearForTesting();
    AuthSessionService.instance.clearMemoryForTesting();
  });

  testWidgets('signup starts with a role choice before the form', (
    tester,
  ) async {
    await pumpWelcome(tester);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Are you a'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Farmer'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Buyer'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Rider'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Buyer'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Sign up'));
    await tester.pump();

    expect(find.text('Enter your first name.'), findsOneWidget);
    expect(find.text('Are you a'), findsNothing);
  });

  testWidgets('buyer role opens buyer home after signup', (tester) async {
    await pumpRoleSelection(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Buyer'));
    await tester.pumpAndSettle();
    await enterValidSignUpDetails(tester, email: 'Ana@Example.com');
    final signUpButton = find.widgetWithText(FilledButton, 'Sign up');
    await tester.ensureVisible(signUpButton);
    await tester.tap(signUpButton);
    await tester.pumpAndSettle();

    final account = AuthRegistrationService.instance.registeredAccounts.single;

    expect(account.firstName, 'Ana');
    expect(account.lastName, 'Reyes');
    expect(account.email, 'ana@example.com');
    expect(account.extensionName, 'Jr.');
    expect(account.phoneNumber, '+639171234567');
    expect(account.dateOfBirth, '2000-01-01');
    expect(account.shippingAddress, 'Purok 5, Lianga, Surigao del Sur');
    expect(account.role, 'buyer');
    expect(find.byType(CustomBottomNavBar), findsOneWidget);
    expect(find.text('Search in AgriSell'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Add new products'), findsNothing);
  });

  testWidgets('farmer role opens the multi-step Farmer signup', (tester) async {
    await pumpRoleSelection(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Farmer'));
    await tester.pumpAndSettle();

    expect(find.byType(FarmerSignUpScreen), findsOneWidget);
    expect(find.text('Step 1 of 3'), findsOneWidget);
    expect(find.text('Account information'), findsOneWidget);
    expect(find.text('Submit registration'), findsNothing);
  });

  testWidgets('rider role opens the rider registration form', (tester) async {
    await pumpRoleSelection(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Rider'));
    await tester.pumpAndSettle();

    expect(find.byType(RiderSignUpScreen), findsOneWidget);
    expect(find.text('Rider Sign-Up'), findsOneWidget);
    expect(find.text('Step 1 of 6'), findsOneWidget);
    expect(find.text('First name'), findsOneWidget);
    expect(find.text('Phone number (09XXXXXXXXX)'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    final firstName = find.byKey(const ValueKey('First name'));
    final middleName = find.byKey(const ValueKey('Middle name (optional)'));
    final lastName = find.byKey(const ValueKey('Last name'));
    expect(
      tester.getTopLeft(middleName).dy - tester.getBottomLeft(firstName).dy,
      10,
    );
    expect(
      tester.getTopLeft(lastName).dy - tester.getBottomLeft(middleName).dy,
      10,
    );
    expect(tester.getSize(firstName).height, tester.getSize(lastName).height);
  });

  testWidgets('rider account returns to the rider dashboard after login', (
    tester,
  ) async {
    await AuthRegistrationService.instance.register(
      const SignUpAccountData(
        firstName: 'Rider',
        lastName: 'One',
        email: 'rider@example.com',
        password: 'password123',
      ),
      AuthRole.rider,
    );
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AgrisellTheme.light,
        home: const LoginScreen(),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Email or phone number'),
      'rider@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'password123',
    );
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Log In'));
    await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
    // Rider Home intentionally keeps reconnect checks alive. Pump through the
    // navigation transition without waiting for every background timer.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.byType(RiderHomeScreen), findsOneWidget);
  });
}
