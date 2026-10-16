import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_home_design_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('rider buttons override the production theme height cap', (
    tester,
  ) async {
    var actions = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: Column(
            children: [
              FilledButton(
                style: RiderHomeDesignStyles.primaryButton,
                onPressed: () => actions++,
                child: const Text('Continue delivery'),
              ),
              TextButton(
                style: RiderHomeDesignStyles.secondaryButton,
                onPressed: () => actions++,
                child: const Text('View earnings'),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Continue delivery'));
    await tester.tap(find.text('View earnings'));
    expect(actions, 2);
  });
}
