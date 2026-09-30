import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_button.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('forgot password screen renders new design elements', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 932);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: const ForgotPasswordScreen(),
      ),
    );
    await tester.pump();

    // Verify Title
    final titleFinder = find.text('Forgot Password');
    expect(titleFinder, findsOneWidget);
    final titleText = tester.widget<Text>(titleFinder);
    expect(titleText.style?.color, AgrisellColors.authGreen);
    expect(titleText.style?.fontWeight, FontWeight.w700);

    // Verify Subtitle
    final subtitleFinder = find.text(
      'Enter your email address and we will send a password-reset code.',
    );
    expect(subtitleFinder, findsOneWidget);
    final subtitleText = tester.widget<Text>(subtitleFinder);
    expect(subtitleText.textAlign, TextAlign.center);

    // Verify Email field with mail icon
    expect(find.byType(AuthTextField), findsOneWidget);
    expect(find.byIcon(Icons.mail_outline), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);

    // Verify Send code button
    final sendButtonFinder = find.widgetWithText(AuthPrimaryButton, 'Send code');
    expect(sendButtonFinder, findsOneWidget);
    final sendButton = tester.widget<AuthPrimaryButton>(sendButtonFinder);
    expect(sendButton.borderRadius, 14);
    expect(sendButton.hasShadow, isTrue);

    // Verify Back to login button
    final backFinder = find.widgetWithText(TextButton, 'Back to login');
    expect(backFinder, findsOneWidget);
  });

  testWidgets('back to login pops navigation', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 932);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
            ),
            child: const Text('Open Forgot'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open Forgot'));
    await tester.pumpAndSettle();

    expect(find.text('Forgot Password'), findsOneWidget);

    await tester.tap(find.text('Back to login'));
    await tester.pumpAndSettle();

    expect(find.text('Forgot Password'), findsNothing);
    expect(find.text('Open Forgot'), findsOneWidget);
  });
}
