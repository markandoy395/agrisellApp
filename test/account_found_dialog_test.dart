import 'package:agresell_app/features/auth/presentation/widgets/account_found_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('account found dialog offers both registration choices', (
    tester,
  ) async {
    bool? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async =>
                  selected = await AccountFoundDialog.show(context),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Account Found'), findsOneWidget);
    expect(find.text('Continue Registration'), findsOneWidget);
    await tester.tap(find.text('Continue Registration'));
    await tester.pumpAndSettle();
    expect(selected, isTrue);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use a Different Email'));
    await tester.pumpAndSettle();
    expect(selected, isFalse);
  });
}
