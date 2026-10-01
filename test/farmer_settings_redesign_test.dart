import 'package:agresell_app/core/services/app_font_size_controller.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/farmer/profile/presentation/screens/farmer_profile_screen.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_profile_edit_card.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_settings_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final width in [320.0, 430.0]) {
    testWidgets(
      'settings sheet at $width edits, returns, scales and dismisses',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        await AppFontSizeController.instance.setTextScale(1);
        addTearDown(() => AppFontSizeController.instance.setTextScale(1));
        await tester.binding.setSurfaceSize(Size(width, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          MaterialApp(
            theme: AgrisellTheme.light,
            home: const Scaffold(
              body: FarmerProfileScreen(showSettingsIcon: true),
            ),
          ),
        );
        await tester.tap(find.byTooltip('Settings'));
        await tester.pumpAndSettle();
        expect(find.byType(DraggableScrollableSheet), findsOneWidget);
        expect(find.byType(FarmerSettingsPanel), findsOneWidget);
        expect(find.text('Account'), findsWidgets);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Edit farmer profile'));
        await tester.pumpAndSettle();
        expect(find.byType(FarmerSettingsPanel), findsNothing);
        expect(find.byType(FarmerProfileEditCard), findsOneWidget);
        expect(find.text('Edit Profile'), findsOneWidget);
        await tester.tap(find.byTooltip('Back'));
        await tester.pumpAndSettle();
        expect(find.byType(FarmerSettingsPanel), findsOneWidget);
        final scrollable = find.descendant(
          of: find.byType(FarmerSettingsPanel),
          matching: find.byType(Scrollable),
        );
        await tester.drag(scrollable, const Offset(0, -200));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Increase font size'));
        await tester.pumpAndSettle();
        expect(find.text('110%'), findsOneWidget);
        expect(AppFontSizeController.instance.textScale, 1.1);
        await tester.tap(find.byTooltip('Decrease font size'));
        await tester.pumpAndSettle();
        expect(find.text('100%'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Logout'),
          150,
          scrollable: scrollable,
        );
        expect(find.text('Switch account'), findsOneWidget);
        expect(find.text('Logout'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip('Close settings'));
        await tester.pumpAndSettle();
        expect(find.byType(FarmerSettingsPanel), findsNothing);
        expect(find.text('Account & Farm'), findsOneWidget);
        await tester.tap(find.byTooltip('Settings'));
        await tester.pumpAndSettle();
        await tester.tapAt(const Offset(8, 10));
        await tester.pumpAndSettle();
        expect(find.byType(FarmerSettingsPanel), findsNothing);
      },
    );
  }
}
