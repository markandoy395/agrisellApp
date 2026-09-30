import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/auth/presentation/screens/login_screen.dart';
import 'package:agresell_app/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:agresell_app/features/auth/presentation/widgets/keyboard_adaptive_scroll_view.dart';
import 'package:agresell_app/features/farmer/registration/presentation/screens/farmer_sign_up_screen.dart';
import 'package:agresell_app/features/rider/profile/presentation/screens/rider_sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('auth forms use no closed-keyboard scroll when space is ample', (
    tester,
  ) async {
    await _setScreen(tester, const Size(430, 932));

    for (final screen in <Widget>[
      const LoginScreen(),
      const SignUpScreen(role: AuthRole.buyer),
      const FarmerSignUpScreen(),
      const RiderSignUpScreen(),
    ]) {
      await _pumpScreen(tester, screen);
      final adaptiveScroll = find.descendant(
        of: find.byType(KeyboardAdaptiveScrollView),
        matching: find.byType(Scrollable),
      );
      expect(adaptiveScroll, findsAtLeastNWidgets(1));
      expect(
        tester
            .state<ScrollableState>(adaptiveScroll.first)
            .position
            .maxScrollExtent,
        0,
        reason: '${screen.runtimeType} should fit without scrolling',
      );
      expect(tester.takeException(), isNull, reason: '${screen.runtimeType}');
    }
  });

  testWidgets('auth forms remain usable on a compact phone', (tester) async {
    await _setScreen(tester, const Size(320, 568));

    final cases = <(Widget, Finder)>[
      (const LoginScreen(), find.widgetWithText(FilledButton, 'Log In')),
      (
        const SignUpScreen(role: AuthRole.buyer),
        find.widgetWithText(FilledButton, 'Continue'),
      ),
      (
        const FarmerSignUpScreen(),
        find.widgetWithText(FilledButton, 'Continue'),
      ),
      (
        const RiderSignUpScreen(),
        find.widgetWithText(FilledButton, 'Continue'),
      ),
    ];

    for (final (screen, action) in cases) {
      await _pumpScreen(tester, screen);
      await tester.ensureVisible(action);
      await tester.pumpAndSettle();
      expect(action, findsOneWidget);
      expect(tester.getBottomLeft(action).dy, lessThanOrEqualTo(568));
      expect(tester.takeException(), isNull, reason: '${screen.runtimeType}');
    }
  });

  testWidgets('signup focused fields stay above the keyboard', (tester) async {
    await _setScreen(tester, const Size(430, 932));
    const keyboardHeight = 330.0;
    const keyboardTop = 602.0;

    final cases = <(Widget, Finder)>[
      (
        const SignUpScreen(role: AuthRole.buyer),
        find.widgetWithText(TextField, 'Confirm Password'),
      ),
      (
        const FarmerSignUpScreen(),
        find.widgetWithText(TextField, 'Confirm password'),
      ),
      (
        const RiderSignUpScreen(),
        find.widgetWithText(TextFormField, 'Confirm password'),
      ),
    ];

    for (final (screen, field) in cases) {
      await _pumpScreen(tester, screen);
      await tester.enterText(field, 'password');
      tester.view.viewInsets = const FakeViewPadding(bottom: keyboardHeight);
      await tester.pumpAndSettle();
      final focusedField = find.byWidgetPredicate(
        (widget) => switch (widget) {
          TextField() => widget.controller?.text == 'password',
          TextFormField() => widget.controller?.text == 'password',
          _ => false,
        },
      );
      expect(
        tester.getBottomLeft(focusedField).dy,
        lessThan(keyboardTop),
        reason: '${screen.runtimeType}',
      );
      expect(tester.takeException(), isNull, reason: '${screen.runtimeType}');
      tester.view.resetViewInsets();
      FocusManager.instance.primaryFocus?.unfocus();
    }
  });

  testWidgets(
    'login returns to its resting position after keyboard dismissal',
    (tester) async {
      await _setScreen(tester, const Size(430, 932));
      await _pumpScreen(tester, const LoginScreen());
      final title = find.text('Welcome Back');
      final initialTop = tester.getTopLeft(title).dy;

      await tester.tap(find.widgetWithText(TextField, 'Password'));
      tester.view.viewInsets = const FakeViewPadding(bottom: 330);
      await tester.pumpAndSettle();
      tester.view.resetViewInsets();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      expect(tester.getTopLeft(title).dy, closeTo(initialTop, .1));
      expect(tester.takeException(), isNull);
    },
  );
}

Future<void> _setScreen(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  await tester.binding.setSurfaceSize(size);
  addTearDown(() {
    tester.view.resetViewInsets();
    tester.view.resetDevicePixelRatio();
    tester.binding.setSurfaceSize(null);
  });
}

Future<void> _pumpScreen(WidgetTester tester, Widget screen) async {
  tester.view.resetViewInsets();
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpWidget(
    MaterialApp(
      theme: AgrisellTheme.light,
      home: KeyedSubtree(key: UniqueKey(), child: screen),
    ),
  );
  await tester.pumpAndSettle();
}
