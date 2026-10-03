import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/farmer/payouts/data/farmer_payout_repository.dart';
import 'package:agresell_app/features/farmer/payouts/domain/farmer_cash_out_request.dart';
import 'package:agresell_app/features/farmer/payouts/domain/farmer_payout.dart';
import 'package:agresell_app/features/farmer/payouts/presentation/screens/farmer_payout_history_screen.dart';
import 'package:agresell_app/features/shared/reporting/widgets/export_report_sheet.dart';

void main() {
  const payout = FarmerPayout(
    payoutId: '1',
    paymentId: '101',
    orderId: '501',
    clientOrderId: '',
    amount: 1000,
    status: FarmerPayoutStatus.paid,
    reference: '  PAYOUT-123  ',
  );
  final rejectedRequest = FarmerCashOutRequest(
    requestId: 'rejected-1',
    amount: 500,
    payoutMethod: 'bank_transfer',
    accountName: 'Farmer Juan',
    accountNumber: '1234567890',
    bankName: 'Landbank',
    status: 'rejected',
    rejectionReason: 'Account verification failed',
    createdAt: DateTime(2026, 9, 18),
  );

  Future<void> openHistory(
    WidgetTester tester,
    FarmerPayoutRepository repository, {
    FarmerPayoutFilter initialFilter = FarmerPayoutFilter.all,
  }) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: FarmerPayoutHistoryScreen(
          repository: repository,
          initialFilter: initialFilter,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('initial failed filter preserves rejected bank request details', (
    tester,
  ) async {
    await openHistory(
      tester,
      InMemoryFarmerPayoutRepository([payout], [rejectedRequest]),
      initialFilter: FarmerPayoutFilter.failed,
    );

    expect(find.text('Order: ORD-501'), findsNothing);
    expect(find.text('Rejected'), findsOneWidget);
    await tester.tap(find.text('Account: Farmer Juan'));
    await tester.pumpAndSettle();

    expect(find.text('Landbank'), findsOneWidget);
    expect(find.text('Sep 18, 2026 · 12:00 AM'), findsOneWidget);
    expect(find.text('Account verification failed'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Cash-Out Request Details'), findsNothing);
  });

  testWidgets(
    'refresh, reference copying, and exporting retain loaded records',
    (tester) async {
      final repository = InMemoryFarmerPayoutRepository();
      await openHistory(tester, repository);
      expect(find.text('No payout records found'), findsOneWidget);

      repository.setPayouts([payout]);
      repository.setCashOutRequests([rejectedRequest]);
      await tester.tap(find.byTooltip('Refresh'));
      await tester.pumpAndSettle();
      expect(find.text('Order: ORD-501'), findsOneWidget);
      expect(find.text('Account: Farmer Juan'), findsOneWidget);

      String? copiedReference;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copiedReference = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(() {
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        );
      });
      await tester.tap(find.byIcon(Icons.copy_rounded));
      await tester.pumpAndSettle();
      expect(copiedReference, 'PAYOUT-123');
      expect(
        find.text('Payout reference copied to clipboard.'),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('Export CSV'));
      await tester.pumpAndSettle();
      final report = tester.widget<ExportReportSheet>(
        find.byType(ExportReportSheet),
      );
      expect(report.title, 'Farmer Payouts Statement');
      expect(report.rows, hasLength(2));
      expect(
        report.fileName,
        matches(r'^farmer_payouts_\d{4}-\d{2}-\d{2}\.csv$'),
      );
    },
  );
}
