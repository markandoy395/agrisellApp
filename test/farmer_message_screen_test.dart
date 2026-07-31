import 'package:agresell_app/core/theme/agrisellTheme.dart';
import 'package:agresell_app/features/farmer/chat/presentation/screens/farmer_message_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('farmer inbox starts empty until backend messages arrive', (
    tester,
  ) async {
    await _pumpFarmerMessages(tester, const Size(430, 932));

    final searchField = find.widgetWithText(
      TextField,
      'Search buyers or products',
    );
    expect(searchField, findsOneWidget);
    expect(find.text('No all messages'), findsOneWidget);

    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();

    expect(find.text('No orders messages'), findsOneWidget);

    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    await tester.enterText(searchField, 'Cucumber');
    await tester.pumpAndSettle();

    expect(find.text('No all messages'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(searchField).controller?.text, isEmpty);
    expect(find.text('No all messages'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('farmer message empty state fits a compact phone', (
    tester,
  ) async {
    await _pumpFarmerMessages(tester, const Size(320, 568));

    final searchField = find.widgetWithText(
      TextField,
      'Search buyers or products',
    );
    expect(searchField, findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.enterText(searchField, 'Pumpkin');
    await tester.pumpAndSettle();

    expect(find.text('No all messages'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpFarmerMessages(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AgrisellTheme.light,
      home: const Scaffold(body: FarmerMessageScreen()),
    ),
  );
  await tester.pumpAndSettle();
}
