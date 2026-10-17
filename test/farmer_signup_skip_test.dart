import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/farmer/registration/presentation/controllers/farmer_signup_controllers.dart';
import 'package:agresell_app/features/farmer/registration/presentation/screens/farmer_registration_submitted_screen.dart';
import 'package:agresell_app/features/farmer/registration/presentation/screens/farmer_sign_up_screen.dart';
import 'package:agresell_app/features/farmer/registration/presentation/widgets/farmer_signup_farm_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  test(
    'skipped farm payload preserves personal data and discards farm draft',
    () {
      final form = FarmerSignupControllers();
      addTearDown(form.dispose);
      form.firstName.text = 'Ana';
      form.farmName.text = 'Unfinished';
      form.farmSize.text = '-12';
      form.latitude.text = '999';
      final payload = form.data(skipFarmDetails: true).toAuthMetadata();
      expect(payload['farm_details_skipped'], isTrue);
      expect(payload['first_name'], 'Ana');
      expect(payload['farm_name'], '');
      expect(payload['farm_size'], isNull);
      expect(payload['latitude'], isNull);
      expect(payload['main_crops'], isEmpty);
      expect(form.farmName.text, 'Unfinished');
      expect(form.data().toAuthMetadata()['farm_details_skipped'], isNull);
    },
  );

  testWidgets(
    'Skip appears only on step 3 and submits without farm validation',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: const FarmerSignUpScreen(),
        ),
      );
      expect(find.text('Skip for now'), findsNothing);
      await enter(tester, 'Email', 'skip@example.com');
      await enter(tester, 'Password', 'Password123!');
      await enter(tester, 'Confirm password', 'Password123!');
      await tap(tester, find.widgetWithText(FilledButton, 'Continue'));
      expect(find.text('Skip for now'), findsNothing);
      await enter(tester, 'First name', 'Ana');
      await enter(tester, 'Last name', 'Reyes');
      await enter(tester, 'Phone number (09XXXXXXXXX)', '09171234567');
      await tap(tester, find.widgetWithText(TextField, 'Date of birth'));
      await tap(tester, find.text('OK'));
      await tap(tester, find.widgetWithText(FilledButton, 'Continue'));
      expect(find.text('3 of 3'), findsOneWidget);
      expect(find.text('Skip for now'), findsOneWidget);
      await enter(tester, 'Farm name', 'Unfinished draft');
      await tap(tester, find.text('Skip for now'));
      expect(find.byType(FarmerRegistrationSubmittedScreen), findsOneWidget);
      expect(find.byType(FarmerSignupFarmStep), findsNothing);
      expect(
        AuthRegistrationService.instance.registeredAccounts.single.firstName,
        'Ana',
      );
      expect(tester.takeException(), isNull);
    },
  );
}

Future<void> enter(WidgetTester tester, String label, String value) async {
  final finder = find.widgetWithText(TextField, label);
  await tester.ensureVisible(finder);
  await tester.enterText(finder, value);
  await tester.pump();
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
