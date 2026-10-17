import 'package:agresell_app/features/auth/presentation/widgets/auth_keyboard_viewport.dart';
import 'package:agresell_app/features/auth/presentation/widgets/forgot_password_reset_step.dart';
import 'package:agresell_app/features/auth/presentation/widgets/keyboard_adaptive_scroll_view.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('keyboard frames preserve form position, focus and child build', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 932);
    tester.view.viewPadding = const FakeViewPadding(bottom: 24);
    addTearDown(tester.view.reset);
    var builds = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          body: AuthKeyboardViewport(
            topPadding: 44,
            scrollable: true,
            child: Builder(
              builder: (_) {
                builds++;
                return const TextField();
              },
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(TextField));
    await tester.pump();
    final initialTop = tester.getTopLeft(find.byType(TextField)).dy;
    final initialBuilds = builds;
    final fieldState = tester.state(find.byType(EditableText));

    for (final inset in [1.0, 100.0, 320.0, 100.0, 1.0, 0.0]) {
      tester.view.viewInsets = FakeViewPadding(bottom: inset);
      await tester.pump();
      expect(tester.getTopLeft(find.byType(TextField)).dy, initialTop);
      expect(builds, initialBuilds);
      expect(tester.state(find.byType(EditableText)), same(fieldState));
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText))
            .focusNode
            .hasFocus,
        isTrue,
      );
      final scroll = tester.widget<KeyboardAdaptiveScrollView>(
        find.byType(KeyboardAdaptiveScrollView),
      );
      expect(scroll.padding, const EdgeInsets.fromLTRB(28, 44, 28, 50));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('password rules and errors keep recovery controls in place', (
    tester,
  ) async {
    final password = TextEditingController();
    final confirmation = TextEditingController();
    final error = ValueNotifier<String?>(null);
    addTearDown(password.dispose);
    addTearDown(confirmation.dispose);
    addTearDown(error.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ForgotPasswordResetStep(
              passwordController: password,
              confirmationController: confirmation,
              confirmationError: error,
              loading: false,
              onPasswordChanged: (_) {},
              onConfirmationChanged: (_) {},
              onUpdatePassword: () {},
              onBackToLogin: () {},
            ),
          ),
        ),
      ),
    );
    final confirmationField = find.byType(AuthTextField).last;
    final initialTop = tester.getTopLeft(confirmationField).dy;
    final buttonTop = tester.getTopLeft(find.text('Update password')).dy;
    for (final value in ['weak', 'Strong123!', '']) {
      password.text = value;
      error.value = value.isEmpty ? null : 'Passwords do not match.';
      await tester.pump();
      expect(tester.getTopLeft(confirmationField).dy, initialTop);
      expect(tester.getTopLeft(find.text('Update password')).dy, buttonTop);
      expect(find.text('Password requirements'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
