import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_farm_edit_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('farm actions render with the app theme and handle taps', (
    tester,
  ) async {
    var cancelCount = 0;
    var saveCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: FarmerFarmEditActions(
            isSaving: false,
            isCapturing: false,
            onCancel: () => cancelCount++,
            onSave: () => saveCount++,
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(OutlinedButton)).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester.getSize(find.byType(FilledButton)).height,
      greaterThanOrEqualTo(48),
    );
    await tester.tap(find.text('Cancel'));
    await tester.tap(find.text('Save Farm'));
    expect(cancelCount, 1);
    expect(saveCount, 1);
  });

  for (final state in [(true, false), (false, true)]) {
    testWidgets('farm actions respect saving/capturing state $state', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            body: FarmerFarmEditActions(
              isSaving: state.$1,
              isCapturing: state.$2,
              onCancel: () {},
              onSave: () {},
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      final cancel = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      final save = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(cancel.onPressed, state.$1 ? isNull : isNotNull);
      expect(save.onPressed, isNull);
      expect(find.text(state.$1 ? 'Saving...' : 'Save Farm'), findsOneWidget);
    });
  }
}
