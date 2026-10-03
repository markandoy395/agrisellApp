import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/auth/data/auth_registration_exception.dart';
import 'package:agresell_app/features/auth/presentation/widgets/otp_verification_screen.dart';

void main() {
  testWidgets('help sheets retain navigation and support details', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: OtpVerificationScreen(
          destination: 'buyer@example.com',
          onVerify: (_) async {},
        ),
      ),
    );
    await tester.tap(
      find.text('I no longer have access to this email address.'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Lost Access to Your Email?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Contact support'));
    await tester.pumpAndSettle();
    expect(find.text('Need Help Signing In?'), findsOneWidget);
    expect(find.text('support@agrisell.com'), findsOneWidget);
    expect(find.text('+63 900 123 4567 (Mon-Fri 8AM-5PM)'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Close'));
    await tester.pumpAndSettle();
    expect(find.text('Need Help Signing In?'), findsNothing);
    expect(find.byType(OtpVerificationScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('successful verification returns true', (tester) async {
    bool? result;
    String? verifiedCode;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => OtpVerificationScreen(
                    destination: 'buyer@example.com',
                    onVerify: (code) async => verifiedCode = code,
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
    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Verify'));
    await tester.pumpAndSettle();
    expect(verifiedCode, '123456');
    expect(result, isTrue);
  });

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
