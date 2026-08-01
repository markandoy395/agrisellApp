import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/auth/presentation/screens/loginScreen.dart';
import 'package:agresell_app/features/auth/presentation/screens/signUpScreen.dart';
import 'package:agresell_app/features/auth/presentation/widgets/authScaffold.dart';
import 'package:agresell_app/features/auth/presentation/widgets/authTextField.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_password_requirements.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('auth field floats its label and shows password requirements', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: Column(
            children: [
              AuthTextField(
                hintText: 'Password',
                controller: controller,
                showPasswordToggle: true,
              ),
              AuthPasswordRequirements(controller: controller),
            ],
          ),
        ),
      ),
    );
    final field = tester.widget<TextField>(find.byType(TextField));
    final decoration = field.decoration!;
    final border = decoration.border! as OutlineInputBorder;
    expect(decoration.hintText, 'Password');
    expect(decoration.labelText, isNull);
    expect(decoration.filled, isTrue);
    for (final stateBorder in [
      decoration.enabledBorder,
      decoration.focusedBorder,
      decoration.errorBorder,
      decoration.focusedErrorBorder,
      decoration.disabledBorder,
    ]) {
      expect(stateBorder, isA<OutlineInputBorder>());
      expect(
        (stateBorder! as OutlineInputBorder).borderRadius,
        border.borderRadius,
      );
    }
    await tester.enterText(find.byType(TextField), 'Password123!');
    await tester.pump();
    final fieldRect = tester.getRect(find.byType(AuthTextField));
    final labelRect = tester.getRect(
      find.byKey(const Key('auth-floating-label')),
    );
    expect(labelRect.top, greaterThanOrEqualTo(fieldRect.top));
    expect(labelRect.bottom, lessThanOrEqualTo(fieldRect.bottom));
    expect(find.text('Password requirements'), findsNothing);
    expect(find.text('At least 8 characters'), findsNothing);
    expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
  });
  testWidgets('compact login field keeps focus when keyboard opens', (
    tester,
  ) async {
    final controller = TextEditingController();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 932);
    addTearDown(() {
      controller.dispose();
      tester.view.resetViewInsets();
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: AuthScaffold(
          title: 'Log In',
          compactCard: true,
          child: Column(
            children: [
              AuthTextField(
                hintText: 'Email or phone number',
                controller: controller,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.byType(TextField));
    await tester.pump();
    tester.view.viewInsets = const FakeViewPadding(bottom: 330);
    await tester.pump();
    final editableText = tester.widget<EditableText>(find.byType(EditableText));
    expect(editableText.focusNode.hasFocus, isTrue);
    await tester.enterText(find.byType(TextField), 'buyer@example.com');
    expect(controller.text, 'buyer@example.com');
  });
  testWidgets('password requirements lay out inside the compact auth card', (
    tester,
  ) async {
    final controller = TextEditingController();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 932);
    addTearDown(() {
      controller.dispose();
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: AuthScaffold(
          title: 'Log In',
          compactCard: true,
          child: Column(
            children: [
              AuthTextField(
                hintText: 'Password',
                controller: controller,
                showPasswordToggle: true,
              ),
              AuthPasswordRequirements(controller: controller),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Password123!');
    await tester.pump();
    expect(find.text('Password requirements'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('all login and sign up fields have matching heights', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 932);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    await tester.pumpWidget(
      MaterialApp(theme: AgrisellTheme.light, home: const LoginScreen()),
    );
    final loginFields = find.byType(AuthTextField);
    final inputSize = tester.getSize(loginFields.first);
    expect(tester.getSize(loginFields.at(1)), inputSize);
    expect(
      tester.getSize(
        find.descendant(
          of: loginFields.first,
          matching: find.byType(InputDecorator),
        ),
      ),
      tester.getSize(
        find.descendant(
          of: loginFields.at(1),
          matching: find.byType(InputDecorator),
        ),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: const SignUpScreen(role: AuthRole.buyer),
      ),
    );
    final signUpFields = find.byType(AuthTextField);
    for (var index = 0; index < 8; index++) {
      expect(tester.getSize(signUpFields.at(index)).height, inputSize.height);
      expect(
        tester.getSize(
          find.descendant(
            of: signUpFields.at(index),
            matching: find.byType(InputDecorator),
          ),
        ),
        Size(tester.getSize(signUpFields.at(index)).width, inputSize.height),
      );
    }
    expect(tester.getSize(signUpFields.at(0)).width, lessThan(inputSize.width));
    expect(tester.getSize(signUpFields.at(1)).width, lessThan(inputSize.width));
  });
  testWidgets('auth fields grow for enlarged text without clipping labels', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 932);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            body: AuthTextField(hintText: 'Email or phone number'),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(tester.getSize(find.byType(AuthTextField)).height, greaterThan(56));
    expect(find.text('Email or phone number'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
