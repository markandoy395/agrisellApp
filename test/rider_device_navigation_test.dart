import 'package:agresell_app/features/rider/dashboard/presentation/screens/rider_home_screen.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_safe_scaffold.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_safe_sheet.dart';
import 'package:agresell_app/features/rider/profile/presentation/styles/rider_profile_edit_styles.dart';
import 'package:agresell_app/features/shared/widgets/navigation/custom_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/rider_dashboard_fakes.dart';
import 'support/rider_dashboard_fixture.dart';

void main() {
  for (final inset in [0.0, 24.0, 48.0]) {
    testWidgets('rider home tabs clear navigation inset $inset', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(384, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final fixture = RiderDashboardFixture(
        dashboardRepository: FakeRiderDashboardRepository(),
      );
      addTearDown(fixture.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(384, 700),
              padding: EdgeInsets.only(bottom: inset),
              viewPadding: EdgeInsets.only(bottom: inset),
            ),
            child: RiderHomeScreen(
              deliveryController: fixture.delivery,
              availabilityController: fixture.availability,
              dashboardController: fixture.dashboard,
              locationController: fixture.location,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final bar = find.byType(CustomBottomNavBar);
      expect(
        tester.getBottomRight(find.byType(PageView)).dy,
        lessThanOrEqualTo(tester.getTopLeft(bar).dy),
      );
      final mapButton = find.text('Map');
      expect(
        tester.getBottomRight(mapButton).dy,
        lessThanOrEqualTo(700 - inset),
      );
      await tester.tap(mapButton);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    for (final keyboard in [0.0, 260.0]) {
      testWidgets(
        'rider pages and sheets clear $inset with keyboard $keyboard',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(384, 700));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          for (final sheet in [false, true]) {
            var pressed = false;
            final action = FilledButton(
              onPressed: () => pressed = true,
              child: const Text('Save changes'),
            );
            final content = Column(
              children: [
                for (var index = 0; index < 8; index++)
                  SizedBox(height: 100, child: Text('Field $index')),
                action,
              ],
            );
            await tester.pumpWidget(
              MaterialApp(
                home: MediaQuery(
                  data: MediaQueryData(
                    size: const Size(384, 700),
                    padding: EdgeInsets.only(
                      bottom: keyboard == 0 ? inset : 0,
                      right: 24,
                    ),
                    viewPadding: EdgeInsets.only(bottom: inset, right: 24),
                    viewInsets: EdgeInsets.only(bottom: keyboard),
                    textScaler: const TextScaler.linear(1.5),
                  ),
                  child: sheet
                      ? Scaffold(
                          resizeToAvoidBottomInset: false,
                          body: RiderSafeSheet(child: content),
                        )
                      : RiderSafeScaffold(
                          body: SingleChildScrollView(child: content),
                        ),
                ),
              ),
            );
            final scroll = tester.state<ScrollableState>(
              find.byType(Scrollable),
            );
            scroll.position.jumpTo(scroll.position.maxScrollExtent);
            await tester.pumpAndSettle();
            final button = find.widgetWithText(FilledButton, 'Save changes');
            expect(
              tester.getBottomRight(button).dy,
              lessThanOrEqualTo(700 - (keyboard == 0 ? inset : keyboard)),
            );
            expect(tester.getBottomRight(button).dx, lessThanOrEqualTo(360));
            await tester.tap(button);
            expect(pressed, isTrue);
            expect(tester.takeException(), isNull);
          }
        },
      );
    }
  }

  testWidgets(
    'profile edit reserves navigation or keyboard without adding both',
    (tester) async {
      for (final keyboard in [0.0, 260.0]) {
        late EdgeInsets padding;
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(
              padding: const EdgeInsets.only(bottom: 48),
              viewInsets: EdgeInsets.only(bottom: keyboard),
            ),
            child: Builder(
              builder: (context) {
                padding = RiderProfileEditStyles.sheetPadding(context);
                return const SizedBox();
              },
            ),
          ),
        );
        expect(padding.bottom, 16 + (keyboard == 0 ? 48 : keyboard));
      }
    },
  );
}
