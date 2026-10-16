import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets('selection toolbar works with app theme at text scale $scale', (
      tester,
    ) async {
      var copied = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light.copyWith(
            platform: TargetPlatform.android,
            visualDensity: VisualDensity.standard,
          ),
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: TextSelectionToolbar(
                anchorAbove: const Offset(200, 200),
                anchorBelow: const Offset(200, 240),
                children: [
                  TextSelectionToolbarTextButton(
                    padding: TextSelectionToolbarTextButton.getPadding(0, 2),
                    onPressed: () => copied = true,
                    child: const Text('Copy'),
                  ),
                  TextSelectionToolbarTextButton(
                    padding: TextSelectionToolbarTextButton.getPadding(1, 2),
                    onPressed: () {},
                    child: const Text('Select all'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Select all'), findsOneWidget);
      await tester.tap(find.text('Copy'));
      await tester.pump();
      expect(copied, isTrue);
      expect(tester.takeException(), isNull);
    });
  }
}
