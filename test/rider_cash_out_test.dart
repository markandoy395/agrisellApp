import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/rider/dashboard/data/rider_analytics_repository.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_analytics_models.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_withdrawal_models.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_wallet.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_analytics_controller.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/screens/rider_earnings_screen.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_cash_out_dialog.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_cash_out_amount_field.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_withdrawal_methods_sheet.dart';

void main() {
  group('Rider Cash-Out & Withdrawal Methods Flow', () {
    testWidgets(
      'RiderWithdrawalMethodsSheet adds and deletes withdrawal methods',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final repository = InMemoryRiderAnalyticsRepository(
          withdrawalMethodsByRider: {
            'rider-1': [
              const RiderWithdrawalMethod(
                methodId: 'wm-1',
                payoutMethod: 'gcash',
                accountName: 'Rider Dave',
                accountNumber: '09171234567',
                isDefault: true,
              ),
            ],
          },
        );
        final controller = RiderAnalyticsController(repository: repository);
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            theme: AgrisellTheme.light,
            home: Scaffold(
              body: RiderWithdrawalMethodsSheet(
                riderId: 'rider-1',
                controller: controller,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Withdrawal Methods'), findsOneWidget);
        expect(find.text('GCash'), findsOneWidget);
        expect(find.text('Rider Dave · 09171234567'), findsOneWidget);
        expect(find.text('DEFAULT'), findsOneWidget);

        // Tap "Add Withdrawal Method"
        await tester.tap(find.text('Add Withdrawal Method'));
        await tester.pumpAndSettle();

        expect(find.text('Account Type'), findsOneWidget);
        expect(find.text('Save Method'), findsOneWidget);

        // Switch to Bank Account
        await tester.tap(find.text('Bank Account'));
        await tester.pumpAndSettle();

        expect(find.text('Bank Name'), findsOneWidget);

        // Fill out form
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Full name on account'),
          'Dave Rider Bank',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Account number'),
          '9876543210',
        );
        await tester.enterText(
          find.widgetWithText(
            TextFormField,
            'e.g. BDO, BPI, Landbank, UnionBank',
          ),
          'BDO',
        );

        await tester.ensureVisible(find.text('Save Method'));
        await tester.tap(find.text('Save Method'));
        await tester.pumpAndSettle();

        // Verify new method appears
        expect(find.text('BDO'), findsOneWidget);
        expect(find.text('Dave Rider Bank · 9876543210'), findsOneWidget);

        // Test delete
        final deleteIcons = find.byIcon(Icons.delete_outline_rounded);
        expect(deleteIcons, findsNWidgets(2));
        await tester.tap(deleteIcons.first);
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
      },
    );

    testWidgets(
      'RiderCashOutDialog validates amount and submits cash-out request',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final repository = InMemoryRiderAnalyticsRepository(
          withdrawalMethodsByRider: {
            'rider-1': [
              const RiderWithdrawalMethod(
                methodId: 'wm-1',
                payoutMethod: 'gcash',
                accountName: 'Dave GCash',
                accountNumber: '09171234567',
                isDefault: true,
              ),
            ],
          },
        );
        final controller = RiderAnalyticsController(repository: repository);
        addTearDown(controller.dispose);

        await controller.loadWithdrawalMethods(riderId: 'rider-1');

        await tester.pumpWidget(
          MaterialApp(
            theme: AgrisellTheme.light,
            home: Scaffold(
              body: RiderCashOutDialog(
                riderId: 'rider-1',
                controller: controller,
                availableEarnings: 1200,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Cash Out Earnings'), findsOneWidget);
        expect(find.text('Available to Withdraw'), findsOneWidget);
        expect(find.text('₱1200.00'), findsOneWidget);

        // Tap quick chip ₱500
        await tester.tap(find.text('₱500'));
        await tester.pumpAndSettle();

        final amountField = tester.widget<TextFormField>(
          find.descendant(
            of: find.byType(RiderCashOutAmountField),
            matching: find.byType(TextFormField),
          ),
        );
        expect(amountField.controller!.text, '500.00');

        // Submit
        await tester.ensureVisible(find.text('Submit Cash Out'));
        await tester.tap(find.text('Submit Cash Out'));
        await tester.pumpAndSettle();

        // Check request was saved in controller
        await controller.loadWithdrawalRequests(riderId: 'rider-1');
        expect(controller.withdrawalRequests.length, 1);
        expect(controller.withdrawalRequests.first.amount, 500);
        expect(controller.withdrawalRequests.first.accountName, 'Dave GCash');
      },
    );

    testWidgets(
      'RiderEarningsScreen displays Withdrawal Methods and Cash Out buttons',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final repository = _WalletAnalyticsRepository(
          earningsByRider: {
            'rider-1': const RiderEarningsData(
              summary: RiderEarningsSummary(
                deliveryEarnings: 1500,
                completedDeliveries: 10,
                paidEarnings: 500,
                pendingPayments: 1000,
              ),
            ),
          },
          withdrawalMethodsByRider: {
            'rider-1': [
              const RiderWithdrawalMethod(
                methodId: 'wm-1',
                payoutMethod: 'gcash',
                accountName: 'Dave Rider',
                accountNumber: '09171234567',
                isDefault: true,
              ),
            ],
          },
        );
        final controller = RiderAnalyticsController(repository: repository);
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            theme: AgrisellTheme.light,
            home: RiderEarningsScreen(
              riderId: 'rider-1',
              controller: controller,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byTooltip('Withdrawal methods'), findsOneWidget);
        expect(find.text('Cash Out'), findsWidgets);

        // Tap Withdrawal Methods in header -> opens sheet
        await tester.tap(find.byTooltip('Withdrawal methods'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Manage your GCash and bank accounts for earnings payouts.',
          ),
          findsOneWidget,
        );

        // Close sheet
        final sheetCloseButton = find.descendant(
          of: find.byType(RiderWithdrawalMethodsSheet),
          matching: find.byIcon(Icons.close_rounded),
        );
        await tester.tap(sheetCloseButton);
        await tester.pumpAndSettle();

        // Tap Cash Out -> opens dialog
        await tester.tap(find.text('Cash Out').first);
        await tester.pumpAndSettle();

        expect(find.text('Cash Out Earnings'), findsOneWidget);
        expect(find.text('Submit Cash Out'), findsOneWidget);
      },
    );
  });
}

class _WalletAnalyticsRepository extends InMemoryRiderAnalyticsRepository
    implements RiderWalletRepository {
  _WalletAnalyticsRepository({
    super.earningsByRider,
    super.withdrawalMethodsByRider,
  });

  @override
  Future<RiderWallet> fetchWallet() async => const RiderWallet(available: 1000);
}
