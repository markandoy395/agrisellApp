import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/farmer/payouts/domain/farmer_cash_out_request.dart';
import 'package:agresell_app/features/farmer/payouts/presentation/controllers/farmer_cash_out_form_controller.dart';
import 'package:agresell_app/features/farmer/payouts/presentation/widgets/farmer_cash_out_dialog.dart';

Future<void> openDialog(
  WidgetTester tester, {
  required Future<FarmerCashOutRequest> Function(FarmerCashOutRequest) onSubmit,
  ValueChanged<FarmerCashOutRequest?>? onResult,
}) async {
  tester.view.physicalSize = const Size(800, 1100);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AgrisellTheme.light,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              final result = await FarmerCashOutDialog.show(
                context,
                initialAmount: 1500,
                onSubmit: onSubmit,
              );
              onResult?.call(result);
            },
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Full name on account'),
    ' Farmer Juan ',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, '09XXXXXXXXX'),
    '09171234567',
  );
}

void main() {
  test('initial amounts and validation retain existing rules', () {
    for (final value in [null, 0.0, -1.0, 99.75]) {
      final form = FarmerCashOutFormController(initialAmount: value);
      expect(form.amount.text, value == 99.75 ? '100' : '');
      form.dispose();
    }
    final form = FarmerCashOutFormController();
    addTearDown(form.dispose);
    expect(form.validateAmount(' '), 'Please enter an amount');
    expect(
      form.validateAmount('0'),
      'Please enter a valid amount greater than 0',
    );
    expect(
      form.validateAmount('invalid'),
      'Please enter a valid amount greater than 0',
    );
    expect(form.validateAmount(' 10.50 '), isNull);
    expect(form.validateAccountName(' '), 'Account name is required');
    expect(form.validateAccountNumber('09 171234567'), isNull);
    expect(
      form.validateAccountNumber('12345'),
      'Enter a valid 11-digit GCash number (09XXXXXXXXX)',
    );
    form.selectMethod('bank_transfer');
    expect(form.validateAccountNumber(''), 'Account number is required');
    expect(form.validateAccountNumber('12345'), isNull);
    expect(
      form.validateBankName(''),
      'Bank name is required for bank transfers',
    );
    form.selectMethod('gcash');
    expect(form.validateBankName(''), isNull);
  });

  testWidgets('submission disables actions, shows failures, and allows retry', (
    tester,
  ) async {
    var attempts = 0;
    FarmerCashOutRequest? result;
    final pending = Completer<FarmerCashOutRequest>();
    await openDialog(
      tester,
      onSubmit: (request) async {
        attempts++;
        if (attempts == 1) return pending.future;
        return request;
      },
      onResult: (value) => result = value,
    );
    final submit = find.widgetWithText(ElevatedButton, 'Submit Request');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    expect(
      tester
          .widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Cancel'))
          .onPressed,
      isNull,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.completeError(Exception('Unavailable'));
    await tester.pumpAndSettle();
    expect(
      find.text('Failed to submit cash-out request: Exception: Unavailable'),
      findsOneWidget,
    );
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(result?.accountName, 'Farmer Juan');
    expect(result?.amount, 1500);
    expect(result?.payoutMethod, 'gcash');
    expect(result?.bankName, '');
    expect(find.byType(FarmerCashOutDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'switching methods retains inputs and omits bank name for GCash',
    (tester) async {
      FarmerCashOutRequest? result;
      await openDialog(
        tester,
        onSubmit: (request) async => request,
        onResult: (value) => result = value,
      );
      await tester.tap(find.text('Bank Transfer'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'e.g. BDO, BPI, Landbank, UnionBank',
        ),
        ' Landbank ',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Add any notes for admin review'),
        ' Harvest payout ',
      );
      await tester.tap(find.text('GCash'));
      await tester.pumpAndSettle();
      expect(find.text('Bank Name'), findsNothing);
      expect(find.text('09171234567'), findsOneWidget);
      await tester.tap(find.text('Bank Transfer'));
      await tester.pumpAndSettle();
      expect(find.text(' Landbank '), findsOneWidget);
      await tester.tap(find.text('GCash'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Submit Request'));
      await tester.tap(find.text('Submit Request'));
      await tester.pumpAndSettle();
      expect(result?.bankName, '');
      expect(result?.notes, 'Harvest payout');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('closing during submission safely ignores late completion', (
    tester,
  ) async {
    final pending = Completer<FarmerCashOutRequest>();
    late FarmerCashOutRequest submitted;
    await openDialog(
      tester,
      onSubmit: (request) {
        submitted = request;
        return pending.future;
      },
    );
    await tester.ensureVisible(find.text('Submit Request'));
    await tester.tap(find.text('Submit Request'));
    await tester.pump();
    await tester.ensureVisible(find.byIcon(Icons.close_rounded));
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    pending.complete(submitted);
    await tester.pumpAndSettle();
    expect(find.byType(FarmerCashOutDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
