import 'dart:typed_data';

import 'package:agresell_app/core/theme/agrisellTheme.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/screens/farmer_dashboard_screen.dart';
import 'package:agresell_app/features/shared/products/domain/product_availability_date_rules.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('farmer dashboard starts empty until backend data arrives', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    expect(find.bySemanticsLabel('AgriSell'), findsOneWidget);
    expect(find.text('Search in AgriSell'), findsOneWidget);
    expect(find.text('Add new products'), findsOneWidget);
    expect(
      find.text('Products from the backend will appear here.'),
      findsOneWidget,
    );
    expect(find.text('Sold'), findsNothing);

    await tester.tap(find.text('Categories'));
    await tester.pumpAndSettle();

    expect(find.text('Vegetables'), findsOneWidget);
    expect(find.text('Fruits'), findsOneWidget);
    expect(find.text('Nuts'), findsOneWidget);
    expect(find.text('Fruit Trees'), findsOneWidget);
    expect(find.text('Spices'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
  });

  testWidgets('add product opens edit screen and saves to farmer grid', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Add new products'));
    await tester.pumpAndSettle();

    expect(find.text('Insert photo'), findsOneWidget);
    expect(find.text('Product details'), findsOneWidget);
    expect(find.text('Product name *'), findsOneWidget);
    expect(find.text('Price / unit *'), findsOneWidget);
    expect(find.text('Available quantity *'), findsOneWidget);
    expect(find.text('Expected availability *'), findsNothing);
    expect(find.byType(TextField), findsNWidgets(5));

    await tester.tap(find.text('Insert photo'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Tomato');
    await tester.enterText(find.byType(TextField).at(1), 'Fresh farm tomatoes');
    await tester.enterText(find.byType(TextField).at(2), '18');
    await tester.enterText(find.byType(TextField).at(3), '40');
    await tester.enterText(find.byType(TextField).at(4), '2');

    await tester.tap(find.byType(DropdownButtonFormField<String>).at(0));
    await tester.pumpAndSettle();
    for (final category in const [
      'Vegetables',
      'Fruits',
      'Nuts',
      'Fruit Trees',
      'Spices',
    ]) {
      expect(find.text(category), findsWidgets);
    }
    await tester.tap(find.text('Vegetables').last);
    await tester.pumpAndSettle();

    await _selectDropdownItem(tester, 2, 'Harvesting soon');
    await _selectDropdownItem(tester, 3, 'Pre-order');
    expect(find.text('Expected availability *'), findsOneWidget);
    expect(
      find.text('Choose a date 3\u201314 days from today.'),
      findsOneWidget,
    );
    final expectedDate = ProductAvailabilityDateRules.philippineToday().add(
      const Duration(days: 3),
    );
    final month = _monthNames[expectedDate.month - 1];
    await tester.ensureVisible(find.text('Select date'));
    await tester.tap(find.text('Select date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.widgetWithText(FilledButton, 'Publish Product'),
      240,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Publish Product'));
    await tester.pumpAndSettle();

    expect(find.text('Tomato has been saved.'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Tomato'), findsOneWidget);
    expect(find.textContaining('\u20B118'), findsOneWidget);
    expect(
      find.text('$month ${expectedDate.day}, ${expectedDate.year}'),
      findsOneWidget,
    );
    expect(find.text('Vegetables'), findsAtLeastNWidgets(1));
  });
}

Future<void> _pumpDashboard(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(430, 932));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AgrisellTheme.light,
      home: Scaffold(
        body: FarmerDashboardScreen(
          pickProductImageBytes: () async => _transparentPng,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _selectDropdownItem(
  WidgetTester tester,
  int index,
  String value,
) async {
  final dropdown = find.byType(DropdownButtonFormField<String>).at(index);
  await tester.ensureVisible(dropdown);
  await tester.pumpAndSettle();
  await tester.tap(dropdown);
  await tester.pumpAndSettle();
  await tester.tap(find.text(value).last);
  await tester.pumpAndSettle();
}

final _transparentPng = Uint8List.fromList([
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
