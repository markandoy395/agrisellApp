import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/shared/reporting/widgets/export_report_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ExportReportSheet renders preview table, metrics, and action buttons', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Mock SystemChannels.platform for Clipboard.setData
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall methodCall) async {
        return null;
      },
    );

    const headers = ['Ref', 'Description', 'Amount'];
    final rows = [
      ['R1', 'Organic Benguet Carrots', '₱1,500.00'],
      ['R2', 'Highland Lettuce', '₱800.00'],
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExportReportSheet(
            title: 'Farmer Payouts Statement',
            fileName: 'farmer_payouts_2026-09-21.csv',
            headers: headers,
            rows: rows,
            totalAmountLabel: '₱2,300.00',
            dateRangeLabel: 'Sep 21, 2026',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title and File Name
    expect(find.text('Farmer Payouts Statement'), findsOneWidget);
    expect(find.text('farmer_payouts_2026-09-21.csv'), findsOneWidget);

    // Verify Summary Metrics
    expect(find.text('Total Records'), findsOneWidget);
    expect(find.text('2 rows'), findsOneWidget);
    expect(find.text('Statement Value'), findsOneWidget);
    expect(find.text('₱2,300.00'), findsOneWidget);
    expect(find.text('Period: Sep 21, 2026'), findsOneWidget);

    // Verify Table Headers and Cells
    expect(find.text('Ref'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('Organic Benguet Carrots'), findsOneWidget);
    expect(find.text('Highland Lettuce'), findsOneWidget);

    // Verify Action Buttons
    expect(find.text('Copy CSV'), findsOneWidget);
    expect(find.text('Save CSV to Device'), findsOneWidget);

    // Tap Copy CSV button
    await tester.ensureVisible(find.text('Copy CSV'));
    await tester.tap(find.text('Copy CSV'));
    await tester.pump();

    // Verify Copied state
    expect(find.text('Copied'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 500));
    // Let snackbar and delayed timer complete
    await tester.pump(const Duration(seconds: 4));
  });
}
