import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/profile_edit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const channel = MethodChannel('agrisell/device_phone_number');

  testWidgets('phone sync starts off and fills the selected device number', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'requestPhoneNumber');
          return '+639171234567';
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: const SignUpScreen(role: AuthRole.buyer),
      ),
    );

    expect(find.text('Sync contact to phone'), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    final phoneField = tester.widget<TextField>(
      find.widgetWithText(TextField, 'Phone Number (09XXXXXXXXX)'),
    );
    expect(phoneField.controller!.text, '09171234567');
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
  });

  testWidgets('profile editor sync fills the selected device number', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => '+639181234567');
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProfileEditCard(
              profile: const UserProfile(
                name: 'Buyer One',
                email: 'buyer@example.com',
                address: '',
                phoneNumber: '09170000000',
                gender: '',
                dateOfBirth: 'January 1, 2000',
                firstName: 'Buyer',
                lastName: 'One',
              ),
              onCancel: () {},
              onSave: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Sync contact to phone'), findsOneWidget);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    final phoneField = tester
        .widgetList<TextField>(find.byType(TextField))
        .singleWhere((field) => field.controller?.text == '09181234567');
    expect(phoneField.controller!.text, '09181234567');
  });
}
