import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/screens/farmer_dashboard_screen.dart';
import 'package:agresell_app/features/farmer/verification/data/farmer_verification_repository.dart';
import 'package:agresell_app/features/farmer/verification/domain/farmer_verification_details.dart';
import 'support/auth_account_fixture.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AuthRegistrationService.instance.clearForTesting();
    AuthSessionService.instance.clearMemoryForTesting();
    final account = await registerTestAccount();
    await AuthSessionService.instance.start(account, rememberMe: false);
  });
  tearDown(() {
    AuthSessionService.instance.clearMemoryForTesting();
    AuthRegistrationService.instance.clearForTesting();
  });
  testWidgets(
    'approval and revocation update the posting button without signing in again',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      var status = 'pending';
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            body: FarmerDashboardScreen(
              verificationRepository: FarmerVerificationRepository(
                customDetailsLoader: () async => FarmerVerificationDetails(
                  verificationStatus: status,
                  accountStatus: 'active',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      FilledButton button() => tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Add new products'),
      );
      expect(button().onPressed, isNull);
      status = 'verified';
      await tester.pump(const Duration(seconds: 30));
      await tester.pumpAndSettle();
      expect(button().onPressed, isNotNull);
      expect(
        AuthSessionService.instance.currentAccount!.isFarmerVerified,
        isFalse,
      );
      status = 'rejected';
      await tester.pump(const Duration(seconds: 30));
      await tester.pumpAndSettle();
      expect(button().onPressed, isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('an approval response after logout cannot enable posting', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final response = Completer<FarmerVerificationDetails?>();
    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: FarmerDashboardScreen(
            verificationRepository: FarmerVerificationRepository(
              customDetailsLoader: () => response.future,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    AuthSessionService.instance.clearMemoryForTesting();
    response.complete(
      const FarmerVerificationDetails(
        verificationStatus: 'verified',
        accountStatus: 'active',
      ),
    );
    await tester.pumpAndSettle();
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Add new products'),
    );
    expect(button.onPressed, isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
