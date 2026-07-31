import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/core/widgets/app_snack_bar.dart';

void main() {
  testWidgets(
    'app SnackBar floats at the bottom and replaces the current one',
    (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (builderContext) {
                context = builderContext;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      ScaffoldMessenger.of(
        context,
      ).showAppSnackBar(const SnackBar(content: Text('First message')));
      await tester.pump();
      ScaffoldMessenger.of(
        context,
      ).showAppSnackBar(const SnackBar(content: Text('Latest message')));
      await tester.pumpAndSettle();

      expect(find.text('First message'), findsNothing);
      expect(find.text('Latest message'), findsOneWidget);
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.behavior, SnackBarBehavior.floating);
      expect(snackBar.duration, const Duration(seconds: 2));
      expect(snackBar.margin, const EdgeInsets.fromLTRB(16, 0, 16, 16));
    },
  );
}
