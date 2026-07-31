import 'package:agresell_app/core/theme/agrisellTheme.dart';
import 'package:agresell_app/features/buyer/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('buyer home starts empty until backend products arrive', (
    tester,
  ) async {
    await _pumpHome(tester);

    expect(find.text('0 products found'), findsOneWidget);
    expect(find.text('No products available'), findsOneWidget);
    expect(
      find.textContaining('No commodities have been posted yet'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('home-product-search')),
      'Pumpkin',
    );
    await tester.pumpAndSettle();

    expect(find.text('0 products found'), findsOneWidget);
    expect(find.byTooltip('Add to basket'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('product filters remain usable while backend data is empty', (
    tester,
  ) async {
    await _pumpHome(tester);

    await tester.tap(find.byKey(const ValueKey('home-product-filter-button')));
    await tester.pumpAndSettle();
    expect(find.text('Filter products'), findsOneWidget);

    await tester.tap(find.text('Accepting orders'));
    await tester.pump();
    await tester.tap(find.text('Show products'));
    await tester.pumpAndSettle();

    expect(find.text('0 products found'), findsOneWidget);
    expect(find.text('No products available'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpHome(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(430, 932));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AgrisellTheme.light,
      home: const HomeScreen(),
    ),
  );
  await tester.pumpAndSettle();
}
