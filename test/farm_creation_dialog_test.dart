import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/farmer/products/presentation/widgets/farm_creation_dialog.dart';

void main() {
  testWidgets('cancelling farm creation closes cleanly with keyboard focus', (
    tester,
  ) async {
    String? result = 'not completed';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                result = await showFarmCreationDialog(context);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Set up your farm'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Temporary farm');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result, isNull);
    expect(find.text('Set up your farm'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty farm names remain in the dialog with an inline error', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () => showFarmCreationDialog(context),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create'));
    await tester.pump();

    expect(find.text('Enter your farm name.'), findsOneWidget);
    expect(find.text('Set up your farm'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('skipping farm name closes dialog and returns empty string', (
    tester,
  ) async {
    String? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                result = await showFarmCreationDialog(context);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Skip'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(result, '');
    expect(find.text('Set up your farm'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
