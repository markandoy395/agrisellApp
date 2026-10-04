import 'support/authenticated_test_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/widgets/farmer_quick_menu.dart';
import 'package:agresell_app/features/farmer/payouts/data/farmer_payout_repository.dart';
import 'package:agresell_app/features/farmer/payouts/domain/farmer_payout.dart';
import 'package:agresell_app/features/farmer/payouts/presentation/screens/farmer_payout_history_screen.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_stats_card.dart';

void main() {
  configureAuthenticatedTests(role: AuthRole.farmer);
  final samplePayouts = [
    FarmerPayout(
      payoutId: '1',
      paymentId: '101',
      orderId: '501',
      clientOrderId: 'ORD-FARM-501',
      amount: 1850.0,
      status: FarmerPayoutStatus.paid,
      reference: 'PAYOUT-GCASH-987654',
      paidAt: DateTime(2026, 9, 16, 14, 0),
      orderTotal: 2000.0,
      buyerName: 'Juan Dela Cruz',
    ),
    FarmerPayout(
      payoutId: '2',
      paymentId: '102',
      orderId: '502',
      clientOrderId: 'ORD-FARM-502',
      amount: 950.0,
      status: FarmerPayoutStatus.approved,
      reference: '',
      approvedAt: DateTime(2026, 9, 17, 9, 30),
      orderTotal: 1000.0,
      buyerName: 'Maria Clara',
    ),
    FarmerPayout(
      payoutId: '3',
      paymentId: '103',
      orderId: '503',
      clientOrderId: 'ORD-FARM-503',
      amount: 500.0,
      status: FarmerPayoutStatus.failed,
      reference: 'PAYOUT-FAIL-111',
      failureReason: 'Invalid GCash account number',
      orderTotal: 550.0,
      buyerName: 'Pedro Penduko',
    ),
  ];

  testWidgets(
    'FarmerPayoutHistoryScreen renders metrics, tabs, and filters payouts',
    (tester) async {
      final repository = InMemoryFarmerPayoutRepository(samplePayouts);

      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: FarmerPayoutHistoryScreen(repository: repository),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Metrics
      expect(find.text('Total Disbursed'), findsOneWidget);
      expect(find.text('Pending Payouts'), findsOneWidget);
      expect(find.text('1 completed'), findsOneWidget);
      expect(find.text('1 in transit'), findsOneWidget);

      // Verify all 3 payouts appear in 'All' tab
      expect(find.text('Order: ORD-FARM-501'), findsOneWidget);
      expect(find.text('Order: ORD-FARM-502'), findsOneWidget);
      expect(find.text('Order: ORD-FARM-503'), findsOneWidget);

      // Filter to 'Paid'
      await tester.tap(find.widgetWithText(Tab, 'Paid'));
      await tester.pumpAndSettle();

      expect(find.text('Order: ORD-FARM-501'), findsOneWidget);
      expect(find.text('Order: ORD-FARM-502'), findsNothing);
      expect(find.text('Order: ORD-FARM-503'), findsNothing);

      // Filter to 'Pending'
      await tester.tap(find.widgetWithText(Tab, 'Pending'));
      await tester.pumpAndSettle();

      expect(find.text('Order: ORD-FARM-502'), findsOneWidget);
      expect(find.text('Order: ORD-FARM-501'), findsNothing);
      expect(find.text('Order: ORD-FARM-503'), findsNothing);

      // Filter to 'Failed'
      await tester.tap(find.widgetWithText(Tab, 'Failed'));
      await tester.pumpAndSettle();

      expect(find.text('Order: ORD-FARM-503'), findsOneWidget);
      expect(find.text('Order: ORD-FARM-501'), findsNothing);
      expect(find.text('Order: ORD-FARM-502'), findsNothing);
    },
  );

  testWidgets('Tapping payout card opens details sheet with breakdown', (
    tester,
  ) async {
    final repository = InMemoryFarmerPayoutRepository([samplePayouts.first]);

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: FarmerPayoutHistoryScreen(repository: repository),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Order: ORD-FARM-501'));
    await tester.pumpAndSettle();

    expect(find.text('Disbursement Details'), findsOneWidget);
    expect(find.text('Disbursement Breakdown'), findsOneWidget);
    expect(find.text('Juan Dela Cruz'), findsOneWidget);
    expect(find.text('PAYOUT-GCASH-987654'), findsWidgets);
  });

  testWidgets('FarmerQuickMenu includes Payouts destination', (tester) async {
    FarmerQuickDestination? selected;

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                selected = await showFarmerQuickMenu(
                  context,
                  current: FarmerQuickDestination.products,
                );
              },
              child: const Text('Open Menu'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Menu'));
    await tester.pumpAndSettle();

    expect(find.text('Payouts'), findsOneWidget);

    await tester.tap(find.text('Payouts'));
    await tester.pumpAndSettle();

    expect(selected, FarmerQuickDestination.payouts);
  });

  testWidgets('FarmerStatsCard opens FarmerPayoutHistoryScreen on tap', (
    tester,
  ) async {
    final repository = InMemoryFarmerPayoutRepository(samplePayouts);

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(body: FarmerStatsCard(repository: repository)),
      ),
    );

    expect(find.text('Payouts & Disbursements'), findsOneWidget);

    await tester.tap(find.text('Payouts & Disbursements'));
    await tester.pumpAndSettle();

    expect(find.byType(FarmerPayoutHistoryScreen), findsOneWidget);
  });
}
