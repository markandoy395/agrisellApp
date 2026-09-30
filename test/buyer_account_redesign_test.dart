import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agresell_app/core/services/app_font_size_controller.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/buyer/profile/presentation/screens/profile_screen.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/profile_edit_card.dart';

void main() {
  for (final width in [360.0, 430.0]) {
    testWidgets(
      'buyer account screen displays all features and toggles personal info at $width',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        await AppFontSizeController.instance.setTextScale(1);
        addTearDown(() => AppFontSizeController.instance.setTextScale(1));
        await tester.binding.setSurfaceSize(Size(width, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          MaterialApp(
            theme: AgrisellTheme.light,
            home: const Scaffold(body: ProfileScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Title should be 'Account' and no settings icon by default
        expect(find.text('Account'), findsWidgets);
        expect(find.byTooltip('Settings'), findsNothing);

        // 2. Personal information details should NOT be displayed initially
        expect(find.text('Personal information'), findsOneWidget);
        expect(find.text('Display'), findsOneWidget);
        expect(find.text('First name'), findsNothing);
        expect(find.text('Phone number'), findsNothing);

        // 3. Tap 'Display' button to display personal information
        await tester.tap(find.text('Display'));
        await tester.pumpAndSettle();

        expect(find.text('Hide'), findsOneWidget);
        expect(find.text('First name'), findsOneWidget);
        expect(find.text('Phone number'), findsOneWidget);
        expect(find.text('Edit'), findsOneWidget);

        // 4. Tap 'Hide' to collapse personal information again
        await tester.tap(find.text('Hide'));
        await tester.pumpAndSettle();
        expect(find.text('Display'), findsOneWidget);
        expect(find.text('First name'), findsNothing);

        // 5. Test opening Edit Profile via Display -> Edit
        await tester.tap(find.text('Display'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();
        expect(find.byType(ProfileEditCard), findsOneWidget);
        expect(find.text('Edit Profile'), findsOneWidget);

        await tester.tap(find.byTooltip('Back'));
        await tester.pumpAndSettle();
        expect(find.byType(ProfileEditCard), findsNothing);

        // 6. Verify features directly accessible in Account
        expect(find.text('Voucher Wallet & Deals'), findsOneWidget);
        expect(find.text('My orders'), findsOneWidget);

        final scrollable = find.byType(Scrollable).first;

        await tester.scrollUntilVisible(
          find.text('Safety & Emergency SOS'),
          100,
          scrollable: scrollable,
        );
        expect(find.text('Safety & Emergency SOS'), findsOneWidget);
        expect(find.text('Incident History & Status'), findsOneWidget);
        expect(find.text('Customer Support Tickets'), findsOneWidget);

        await tester.scrollUntilVisible(
          find.byTooltip('Increase font size'),
          100,
          scrollable: scrollable,
        );
        await tester.tap(find.byTooltip('Increase font size'));
        await tester.pumpAndSettle();
        expect(find.text('110%'), findsOneWidget);
        expect(AppFontSizeController.instance.textScale, 1.1);

        await tester.tap(find.byTooltip('Decrease font size'));
        await tester.pumpAndSettle();
        expect(find.text('100%'), findsOneWidget);

        await tester.scrollUntilVisible(
          find.text('Log Out'),
          100,
          scrollable: scrollable,
        );
        expect(find.text('Switch Account'), findsOneWidget);
        expect(find.text('Log Out'), findsOneWidget);

        expect(tester.takeException(), isNull);
      },
    );
  }
}
