import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/core/services/system_ui_service.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/shared/widgets/navigation/custom_bottom_nav_bar.dart';

void main() {
  testWidgets('dark device uses a white system bar with dark icons', (
    tester,
  ) async {
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        calls.add(call);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await AgrisellSystemUi.applyAppSystemUi(
      platformBrightness: Brightness.dark,
    );
    await tester.pump();
    final style =
        calls
                .firstWhere(
                  (call) =>
                      call.method == 'SystemChrome.setSystemUIOverlayStyle',
                )
                .arguments
            as Map;
    expect(
      style['systemNavigationBarColor'],
      AgrisellColors.surface.toARGB32(),
    );
    expect(style['systemNavigationBarIconBrightness'], 'Brightness.dark');
    expect(style['systemNavigationBarContrastEnforced'], isFalse);
  });

  testWidgets(
    'navigation and safe-area background stay light when device theme changes',
    (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          themeMode: ThemeMode.light,
          home: Scaffold(
            bottomNavigationBar: Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(padding: const EdgeInsets.only(bottom: 24)),
                child: CustomBottomNavBar(
                  items: const [
                    HomeBottomNavItem(
                      label: 'Home',
                      iconData: Icons.home_outlined,
                      activeIconData: Icons.home,
                    ),
                    HomeBottomNavItem(
                      label: 'Account',
                      iconData: Icons.person_outline,
                      activeIconData: Icons.person,
                    ),
                  ],
                  selectedIndex: 1,
                  onItemSelected: (_) {},
                  background: AgrisellColors.surface,
                  activeBackground: AgrisellColors.authGreen,
                  activeIconColor: AgrisellColors.surface,
                  inactiveIconColor: AgrisellColors.brandBlack,
                  inactiveLabelColor: AgrisellColors.brandBlack,
                  shadowColor: Colors.black12,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        MediaQuery.platformBrightnessOf(
          tester.element(find.byType(CustomBottomNavBar)),
        ),
        Brightness.dark,
      );
      final background = find
          .descendant(
            of: find.byType(CustomBottomNavBar),
            matching: find.byType(ColoredBox),
          )
          .first;
      expect(
        tester.widget<ColoredBox>(background).color,
        AgrisellColors.surface,
      );
      expect(
        AgrisellColors.systemNavigationBar(Brightness.light),
        AgrisellColors.surface,
      );
      expect(
        AgrisellColors.systemNavigationBar(Brightness.dark),
        AgrisellColors.surface,
      );
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      await tester.pumpAndSettle();
      expect(
        MediaQuery.platformBrightnessOf(
          tester.element(find.byType(CustomBottomNavBar)),
        ),
        Brightness.light,
      );
      expect(
        tester.widget<ColoredBox>(background).color,
        AgrisellColors.surface,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
