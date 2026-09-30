import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/farmer/payouts/data/farmer_payout_repository.dart';
import 'package:agresell_app/features/farmer/payouts/domain/farmer_cash_out_request.dart';
import 'package:agresell_app/features/farmer/payouts/domain/farmer_payout.dart';
import 'package:agresell_app/features/farmer/payouts/presentation/screens/farmer_payout_history_screen.dart';
import 'package:agresell_app/features/farmer/payouts/presentation/widgets/farmer_cash_out_dialog.dart';

void main() {
  group('Farmer Cash-Out Flow', () {
    testWidgets('FarmerCashOutDialog validates inputs and submits GCash request', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      FarmerCashOutRequest? submitted;

      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            body: FarmerCashOutDialog(
              initialAmount: 1500,
              onSubmit: (req) async {
                submitted = req;
                return req;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Request Cash Out'), findsOneWidget);
      expect(find.text('1500'), findsOneWidget);

      // Attempt submit without account name and number
      await tester.ensureVisible(find.text('Submit Request'));
      await tester.tap(find.text('Submit Request'));
      await tester.pumpAndSettle();

      expect(find.text('Account name is required'), findsOneWidget);
      expect(find.text('GCash mobile number is required'), findsOneWidget);
      expect(submitted, isNull);

      // Enter invalid GCash number
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full name on account'),
        'Farmer Juan',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '09XXXXXXXXX'),
        '12345',
      );
      await tester.ensureVisible(find.text('Submit Request'));
      await tester.tap(find.text('Submit Request'));
      await tester.pumpAndSettle();

      expect(
        find.text('Enter a valid 11-digit GCash number (09XXXXXXXXX)'),
        findsOneWidget,
      );

      // Enter valid GCash number
      await tester.enterText(
        find.widgetWithText(TextFormField, '09XXXXXXXXX'),
        '09171234567',
      );
      await tester.ensureVisible(find.text('Submit Request'));
      await tester.tap(find.text('Submit Request'));
      await tester.pumpAndSettle();

      expect(submitted, isNotNull);
      expect(submitted!.amount, 1500);
      expect(submitted!.payoutMethod, 'gcash');
      expect(submitted!.accountName, 'Farmer Juan');
      expect(submitted!.accountNumber, '09171234567');
    });

    testWidgets('FarmerCashOutDialog switches to Bank Transfer and validates bank name', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1100);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      FarmerCashOutRequest? submitted;

      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            body: FarmerCashOutDialog(
              onSubmit: (req) async {
                submitted = req;
                return req;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Bank Transfer
      await tester.tap(find.text('Bank Transfer'));
      await tester.pumpAndSettle();

      expect(find.text('Bank Name'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter amount (e.g. 1000)'),
        '2500',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full name on account'),
        'Maria Clara',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Account number'),
        '1234567890',
      );

      // Try submit without bank name
      await tester.ensureVisible(find.text('Submit Request'));
      await tester.tap(find.text('Submit Request'));
      await tester.pumpAndSettle();

      expect(
        find.text('Bank name is required for bank transfers'),
        findsOneWidget,
      );

      // Enter bank name
      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g. BDO, BPI, Landbank, UnionBank'),
        'Landbank',
      );
      await tester.ensureVisible(find.text('Submit Request'));
      await tester.tap(find.text('Submit Request'));
      await tester.pumpAndSettle();

      expect(submitted, isNotNull);
      expect(submitted!.amount, 2500);
      expect(submitted!.payoutMethod, 'bank_transfer');
      expect(submitted!.bankName, 'Landbank');
      expect(submitted!.accountName, 'Maria Clara');
      expect(submitted!.accountNumber, '1234567890');
    });

    testWidgets('FarmerPayoutHistoryScreen shows Cash Out buttons, requests, and filters', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

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
      ];
      final sampleRequests = [
        FarmerCashOutRequest(
          requestId: 'req-1',
          amount: 1200.0,
          payoutMethod: 'gcash',
          accountName: 'Farmer Pedro',
          accountNumber: '09181234567',
          status: 'pending',
          createdAt: DateTime(2026, 9, 18, 10, 0),
        ),
      ];

      final repository = InMemoryFarmerPayoutRepository(
        samplePayouts,
        sampleRequests,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: FarmerPayoutHistoryScreen(repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      // Check header button and app bar button
      expect(find.text('Request Payout / Cash Out'), findsOneWidget);
      expect(find.text('Cash Out'), findsWidgets);

      // Check both order payout and manual cash-out request are rendered
      expect(find.text('Order: ORD-FARM-501'), findsOneWidget);
      expect(find.text('Account: Farmer Pedro'), findsOneWidget);
      expect(find.text('Pending Approval'), findsOneWidget);

      // Filter to Pending -> only the pending request should appear
      await tester.tap(find.widgetWithText(Tab, 'Pending'));
      await tester.pumpAndSettle();

      expect(find.text('Account: Farmer Pedro'), findsOneWidget);
      expect(find.text('Order: ORD-FARM-501'), findsNothing);

      // Filter to Paid -> only order payout should appear
      await tester.tap(find.widgetWithText(Tab, 'Paid'));
      await tester.pumpAndSettle();

      expect(find.text('Order: ORD-FARM-501'), findsOneWidget);
      expect(find.text('Account: Farmer Pedro'), findsNothing);

      // Tapping Cash Out button opens dialog
      await tester.tap(find.text('Cash Out').first);
      await tester.pumpAndSettle();

      expect(find.text('Request Cash Out'), findsOneWidget);
    });

    testWidgets('Tapping cash-out card opens cash-out details sheet', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final sampleRequests = [
        FarmerCashOutRequest(
          requestId: 'req-1',
          amount: 1200.0,
          payoutMethod: 'gcash',
          accountName: 'Farmer Pedro',
          accountNumber: '09181234567',
          status: 'pending',
          notes: 'Urgent harvest payout',
          createdAt: DateTime(2026, 9, 18, 10, 0),
        ),
      ];

      final repository = InMemoryFarmerPayoutRepository([], sampleRequests);

      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: FarmerPayoutHistoryScreen(repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Account: Farmer Pedro'));
      await tester.pumpAndSettle();

      expect(find.text('Cash-Out Request Details'), findsOneWidget);
      expect(find.text('Withdrawal Information'), findsOneWidget);
      expect(find.text('Farmer Pedro'), findsOneWidget);
      expect(find.text('09181234567'), findsOneWidget);
      expect(find.text('Urgent harvest payout'), findsOneWidget);
    });
  });
}
