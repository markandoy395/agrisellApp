import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/auth/data/auth_registration_exception.dart';
import 'package:agresell_app/features/auth/presentation/widgets/otp_verification_screen.dart';

void main() {
  testWidgets('uses six digits and locks after five invalid attempts', (
    tester,
  ) async {
    var resendCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: OtpVerificationScreen(
          destination: 'buyer@example.com',
          resendCooldown: Duration.zero,
          onVerify: (_) async => throw const AuthOtpException(
            'That OTP is invalid.',
            reason: AuthOtpFailureReason.invalid,
          ),
          onResend: () async => resendCount++,
        ),
      ),
    );

    expect(
      tester
          .widget<OtpVerificationScreen>(find.byType(OtpVerificationScreen))
          .codeLength,
      6,
    );
    await tester.enterText(find.byType(TextField), '123456');
    for (var attempt = 0; attempt < 5; attempt++) {
      await tester.tap(find.widgetWithText(FilledButton, 'Verify'));
      await tester.pump();
      await tester.pump();
    }

    expect(
      find.text('Too many incorrect attempts. Request a new OTP to continue.'),
      findsOneWidget,
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );

    await tester.tap(find.text('Resend code'));
    await tester.pump();
    await tester.pump();

    expect(resendCount, 1);
    expect(find.text('A new OTP was sent to your email.'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('change email returns to the signup form', (tester) async {
    bool? result;
    var changeEmailCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => OtpVerificationScreen(
                    destination: 'farmer@example.com',
                    changeDestinationLabel: 'Change email',
                    onChangeDestination: () => changeEmailCalls++,
                    onVerify: (_) async {},
                  ),
                ),
              );
            },
            child: const Text('Open OTP'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open OTP'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Change email'));
    await tester.pumpAndSettle();

    expect(result, false);
    expect(changeEmailCalls, 1);
  });
}
