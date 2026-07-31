import 'package:agresell_app/core/theme/agrisellTheme.dart';
import 'package:agresell_app/features/buyer/home/presentation/screens/farmer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('farmer list starts empty until backend profiles arrive', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: const Scaffold(body: FarmerScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('0 farmers found'), findsOneWidget);
    expect(find.text('No farmers found'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Follow'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Shop'), findsNothing);

    await tester.enterText(
      find.widgetWithText(TextField, 'Search farmers, places, or produce'),
      'Bukidnon',
    );
    await tester.pumpAndSettle();
    expect(find.text('0 farmers found'), findsOneWidget);
    expect(find.text('No farmers found'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
