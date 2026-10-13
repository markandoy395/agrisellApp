import 'support/authenticated_test_session.dart';
import 'package:agresell_app/core/services/app_font_size_controller.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/farmer/profile/presentation/screens/farmer_profile_screen.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_profile_edit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  configureAuthenticatedTests(role: AuthRole.farmer);
  for (final width in [320.0, 430.0]) {
    testWidgets('farmer account at $width works without settings', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      await AppFontSizeController.instance.setTextScale(1);
      addTearDown(() => AppFontSizeController.instance.setTextScale(1));
      await tester.binding.setSurfaceSize(Size(width, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: const Scaffold(body: FarmerProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byTooltip('Settings'), findsNothing);
      expect(find.byType(DraggableScrollableSheet), findsNothing);
      expect(find.text('Account & Farm'), findsOneWidget);
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('Display'),
        150,
        scrollable: scrollable,
      );
      await tester.tap(find.text('Display'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Edit'),
        150,
        scrollable: scrollable,
      );
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      expect(find.byType(FarmerProfileEditCard), findsOneWidget);
      tester.state<ScrollableState>(scrollable).position.jumpTo(0);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.byType(FarmerProfileEditCard), findsNothing);
      expect(find.byType(DraggableScrollableSheet), findsNothing);
      expect(find.byTooltip('Settings'), findsNothing);
      await tester.scrollUntilVisible(
        find.byTooltip('Increase font size'),
        150,
        scrollable: scrollable,
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byTooltip('Increase font size'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Increase font size'));
      await tester.pumpAndSettle();
      expect(AppFontSizeController.instance.textScale, 1.1);
      await tester.tap(find.byTooltip('Decrease font size'));
      await tester.pumpAndSettle();
      expect(AppFontSizeController.instance.textScale, 1);
      await tester.scrollUntilVisible(
        find.text('Log Out'),
        150,
        scrollable: scrollable,
      );
      expect(find.text('Switch Account'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
