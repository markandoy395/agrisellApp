import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_profile_edit_card.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_profile_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const profile = UserProfile(
  name: 'Maria Santos',
  firstName: 'Maria',
  lastName: 'Santos',
  email: 'maria@example.com',
  address: '',
  phoneNumber: '09171234567',
  gender: '',
  dateOfBirth: 'January 31, 2000',
);

void main() {
  for (final width in [320.0, 430.0]) {
    testWidgets('farmer edit at $width validates, syncs, saves and cancels', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(width, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      const channel = MethodChannel('agrisell/device_phone_number');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (_) async => '+639181234567',
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );
      UserProfile? saved;
      var cancelled = false;
      var backed = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData(
                size: Size(width, 900),
                textScaler: const TextScaler.linear(1.3),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      FarmerProfileHeader(
                        profile: profile,
                        isVerified: true,
                        title: 'Edit Profile',
                        onBack: () => backed = true,
                      ),
                      FarmerProfileEditCard(
                        profile: profile,
                        onCancel: () => cancelled = true,
                        onSave: (value) => saved = value,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Personal information'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Back'));
      expect(backed, isTrue);
      final first = find.byKey(const ValueKey('farmer-edit-First name'));
      await tester.ensureVisible(first);
      await tester.enterText(first, '');
      await tester.ensureVisible(find.text('Save changes'));
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(saved, isNull);
      expect(find.text('First Name is required.'), findsOneWidget);
      await tester.ensureVisible(first);
      await tester.enterText(first, 'Mariana');
      await tester.ensureVisible(find.byType(Switch));
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextField>(
              find.byKey(const ValueKey('farmer-edit-Phone number')),
            )
            .controller!
            .text,
        '09181234567',
      );
      final month = find.byKey(const ValueKey('farmer-birth-Month-1'));
      await tester.ensureVisible(month);
      await tester.tap(month);
      await tester.pumpAndSettle();
      await tester.tap(find.text('February').last);
      await tester.pumpAndSettle();
      expect(find.text('29'), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('farmer-edit-Email')))
            .readOnly,
        isTrue,
      );
      await tester.ensureVisible(find.text('Save changes'));
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(saved?.firstName, 'Mariana');
      expect(saved?.phoneNumber, '09181234567');
      expect(saved?.dateOfBirth, 'February 29, 2000');
      await tester.tap(find.text('Cancel'));
      expect(cancelled, isTrue);
      expect(tester.takeException(), isNull);
    });
  }
}
