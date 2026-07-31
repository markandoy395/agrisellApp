import 'package:agresell_app/core/theme/agrisellTheme.dart';
import 'package:agresell_app/features/farmer/registration/presentation/screens/farmer_sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const phoneChannel = MethodChannel('agrisell/device_phone_number');

  testWidgets(
    'Farmer signup validates account details and preserves them back',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: const FarmerSignUpScreen(),
        ),
      );

      expect(find.text('Step 1 of 3'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await tester.pump();
      expect(find.text('Enter a valid email address.'), findsOneWidget);

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
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Continue'));
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Step 2 of 3'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Email'), findsNothing);
      expect(find.widgetWithText(TextField, 'Password'), findsNothing);
      expect(find.widgetWithText(TextField, 'Confirm password'), findsNothing);
      expect(find.text('Sync contact to phone'), findsOneWidget);
      expect(find.text('Male'), findsOneWidget);
      expect(find.text('Female'), findsOneWidget);
      expect(
        find.widgetWithText(TextField, 'Street / address line (manual entry)'),
        findsOneWidget,
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('farmer-gender-female')),
      );
      await tester.tap(find.byKey(const ValueKey('farmer-gender-female')));
      await tester.pump();
      expect(find.byIcon(Icons.radio_button_checked_rounded), findsOneWidget);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(phoneChannel, (_) async => '+639171234567');
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(phoneChannel, null),
      );
      await tester.ensureVisible(find.text('Sync contact to phone'));
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextField>(
              find.widgetWithText(TextField, 'Phone number (09XXXXXXXXX)'),
            )
            .controller!
            .text,
        '09171234567',
      );
      await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Back'));
      await tester.tap(find.widgetWithText(OutlinedButton, 'Back'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.widgetWithText(TextField, 'Email'))
            .controller!
            .text,
        'farmer@example.com',
      );
    },
  );

  testWidgets('Farmer signup personal details can be scrolled', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 640));
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
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    final scrollView = find.byKey(
      const PageStorageKey('farmer-signup-step-scroll'),
    );
    final scrollable = tester.state<ScrollableState>(scrollView);
    expect(scrollable.position.maxScrollExtent, greaterThan(0));

    await tester.drag(scrollView, const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(scrollable.position.pixels, greaterThan(0));
  });
}
