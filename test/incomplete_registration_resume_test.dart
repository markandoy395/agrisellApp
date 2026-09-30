import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:agresell_app/features/farmer/registration/presentation/screens/farmer_sign_up_screen.dart';
import 'package:agresell_app/features/rider/profile/data/rider_sign_up_availability_service.dart';
import 'package:agresell_app/features/rider/profile/data/rider_sign_up_draft_storage.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_draft.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_validator.dart';
import 'package:agresell_app/features/rider/profile/presentation/controllers/rider_sign_up_controller.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_registration_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(AuthRegistrationService.instance.clearForTesting);
  tearDown(AuthRegistrationService.instance.clearForTesting);

  testWidgets('Buyer can continue an existing unfinished registration', (
    tester,
  ) async {
    AuthRegistrationService.instance.setEmailStarterForTesting((
      _,
      _,
      role,
    ) async {
      expect(role, AuthRole.buyer);
      throw const AuthIncompleteRegistrationFound(emailVerified: true);
    });
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: const SignUpScreen(role: AuthRole.buyer),
      ),
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Email'),
      'buyer@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'Password123!',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Confirm Password'),
      'Password123!',
    );
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Continue'));
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Account Found'), findsOneWidget);
    await tester.tap(find.text('Continue Registration'));
    await tester.pumpAndSettle();
    expect(find.text('2 of 2'), findsOneWidget);
  });

  testWidgets('Farmer can continue an existing unfinished registration', (
    tester,
  ) async {
    AuthRegistrationService.instance.setEmailStarterForTesting((
      _,
      _,
      role,
    ) async {
      expect(role, AuthRole.farmer);
      throw const AuthIncompleteRegistrationFound(emailVerified: true);
    });
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(theme: AgrisellTheme.light, home: const FarmerSignUpScreen()),
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Email'),
      'farmer@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'Password123!',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Confirm password'),
      'Password123!',
    );
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Continue'));
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Account Found'), findsOneWidget);
    await tester.tap(find.text('Continue Registration'));
    await tester.pumpAndSettle();
    expect(find.text('2 of 3'), findsOneWidget);
  });

  testWidgets('Rider can continue an existing unfinished registration', (
    tester,
  ) async {
    final controller = RiderSignUpController(
      storage: _MemoryDraftStorage(),
      availability: _AvailableRiderFields(),
    );
    addTearDown(controller.dispose);
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: RiderRegistrationForm(
            controller: controller,
            onExit: () async {},
            onSubmitted: (_) {},
            onEmailOtpRequired: (_, _) async => false,
            onStartEmailVerification: (_, _) async =>
                throw const AuthIncompleteRegistrationFound(
                  emailVerified: true,
                ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    controller.updateValue(RiderSignUpFields.email, 'rider@example.com');
    controller.updateSensitive(
      password: 'Password123!',
      confirmPassword: 'Password123!',
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(
      controller.availabilityFor(RiderSignUpFields.email),
      RiderFieldAvailability.available,
    );
    expect(controller.draft.step, RiderSignUpStep.account);
    expect(controller.password, 'Password123!');
    expect(controller.confirmPassword, 'Password123!');
    expect(
      RiderSignUpValidator.stepError(
        draft: controller.draft,
        step: controller.draft.step,
        licenseNumber: controller.licenseNumber,
        password: controller.password,
        confirmPassword: controller.confirmPassword,
      ),
      isNull,
    );
    expect(controller.canContinue, isTrue);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Account Found'), findsOneWidget);
    await tester.tap(find.text('Continue Registration'));
    await tester.pumpAndSettle();
    expect(controller.draft.step, RiderSignUpStep.personal);
  });
}

class _MemoryDraftStorage implements RiderSignUpDraftStorage {
  RiderSignUpDraft? draft;

  @override
  Future<RiderSignUpDraft?> load() async => draft;

  @override
  Future<void> save(RiderSignUpDraft value) async => draft = value;

  @override
  Future<void> clear() async => draft = null;
}

class _AvailableRiderFields extends RiderSignUpAvailabilityService {
  @override
  Future<bool> isEmailAvailable(String value) async => true;

  @override
  Future<bool> isMobileAvailable(String value) async => true;
}
