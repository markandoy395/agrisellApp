import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/features/buyer/orders/presentation/utils/order_dispute_helpers.dart';
import 'package:agresell_app/features/buyer/orders/presentation/widgets/order_dispute_sheet.dart';
import 'package:agresell_app/features/shared/orders/domain/order_dispute.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

void main() {
  testWidgets('validates reasons before submitting', (tester) async {
    var calls = 0;
    await _open(
      tester,
      onSubmit:
          ({
            required orderId,
            required category,
            required reason,
            required requestedResolution,
          }) async {
            calls++;
          },
    );
    await tester.tap(find.text('Submit Dispute Claim'));
    await tester.pumpAndSettle();
    expect(
      find.text('Please describe the condition of the delivered produce.'),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextFormField), 'short');
    await tester.tap(find.text('Submit Dispute Claim'));
    await tester.pumpAndSettle();
    expect(
      find.text('Please provide more details (at least 10 characters).'),
      findsOneWidget,
    );
    expect(calls, 0);
    final field = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(field.validator!('   1234567890   '), isNull);
  });

  testWidgets('submits selected options and trimmed reason then closes', (
    tester,
  ) async {
    String? submittedId;
    String? submittedReason;
    OrderDisputeCategory? submittedCategory;
    OrderDisputeResolution? submittedResolution;
    final completion = Completer<void>();
    await _open(
      tester,
      onSubmit:
          ({
            required orderId,
            required category,
            required reason,
            required requestedResolution,
          }) {
            submittedId = orderId;
            submittedReason = reason;
            submittedCategory = category;
            submittedResolution = requestedResolution;
            return completion.future;
          },
    );
    await tester.tap(
      find.byType(DropdownButtonFormField<OrderDisputeCategory>),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(OrderDisputeCategory.wrongItems.label).last);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byType(DropdownButtonFormField<OrderDisputeResolution>),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(OrderDisputeResolution.replacement.label).last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField),
      '  Incorrect produce was delivered.  ',
    );
    await tester.tap(find.text('Submit Dispute Claim'));
    await tester.pump();
    expect(submittedId, 'ORD-42');
    expect(submittedCategory, OrderDisputeCategory.wrongItems);
    expect(submittedResolution, OrderDisputeResolution.replacement);
    expect(submittedReason, 'Incorrect produce was delivered.');
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    completion.complete();
    await tester.pumpAndSettle();
    expect(find.text('Report Produce Issue'), findsNothing);
    expect(
      find.text('Dispute submitted for administrator review.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('failure preserves defaults and input and allows retry', (
    tester,
  ) async {
    var calls = 0;
    await _open(
      tester,
      onSubmit:
          ({
            required orderId,
            required category,
            required reason,
            required requestedResolution,
          }) async {
            expect(category, OrderDisputeCategory.damagedRottenProduce);
            expect(requestedResolution, OrderDisputeResolution.fullRefund);
            calls++;
            if (calls == 1) throw Exception('Please try again later.');
          },
    );
    await tester.enterText(
      find.byType(TextFormField),
      'The produce was damaged on arrival.',
    );
    await tester.tap(find.text('Submit Dispute Claim'));
    await tester.pumpAndSettle();
    expect(find.text('Please try again later.'), findsOneWidget);
    expect(find.text('Report Produce Issue'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).controller!.text,
      'The produce was damaged on arrival.',
    );
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNotNull,
    );
    await tester.tap(find.text('Submit Dispute Claim'));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.text('Report Produce Issue'), findsNothing);
  });

  testWidgets('pending submission may complete after dismissal', (
    tester,
  ) async {
    for (final fail in [false, true]) {
      final completion = Completer<void>();
      await _open(
        tester,
        onSubmit:
            ({
              required orderId,
              required category,
              required reason,
              required requestedResolution,
            }) => completion.future,
      );
      await tester.enterText(
        find.byType(TextFormField),
        'The produce was damaged on arrival.',
      );
      await tester.tap(find.text('Submit Dispute Claim'));
      await tester.pump();
      final context = tester.element(find.byType(TextFormField));
      Navigator.of(context).pop();
      await tester.pumpAndSettle();
      if (fail) {
        completion.completeError(Exception('Request failed'));
      } else {
        completion.complete();
      }
      await tester.pumpAndSettle();
      expect(find.text('Report Produce Issue'), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('shows all dispute statuses and resolution details then closes', (
    tester,
  ) async {
    for (final status in OrderDisputeStatus.values) {
      final dispute = OrderDispute(
        status: status,
        category: OrderDisputeCategory.missingItems,
        reason: 'A portion of the delivery is missing.',
        requestedResolution: OrderDisputeResolution.partialRefund,
        submittedAt: DateTime(2026, 9, 21, 0, 3),
        resolutionNote: status == OrderDisputeStatus.resolved
            ? 'Partial refund approved.'
            : '   ',
        resolvedAt: DateTime(2026, 9, 22, 12),
      );
      await _open(tester, dispute: dispute);
      expect(find.text('Order Goods Dispute'), findsOneWidget);
      expect(find.text(status.label), findsOneWidget);
      expect(find.text('Missing Items / Incomplete Order'), findsOneWidget);
      expect(find.text('Partial Refund'), findsOneWidget);
      expect(find.text('Sep 21, 2026 · 12:03 AM'), findsOneWidget);
      expect(find.text(dispute.reason), findsOneWidget);
      expect(find.byType(TextFormField), findsNothing);
      expect(
        find.text('Administrator Resolution'),
        status == OrderDisputeStatus.resolved ? findsOneWidget : findsNothing,
      );
      expect(
        find.text('Resolved on Sep 22, 2026 · 12:00 PM'),
        status == OrderDisputeStatus.resolved ? findsOneWidget : findsNothing,
      );
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Order Goods Dispute'), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });

  test('date and error helpers preserve pending and fallback messages', () {
    expect(formatOrderDisputeDate(null), 'Pending');
    expect(
      formatOrderDisputeDate(DateTime(2026, 12, 1, 23, 9)),
      'Dec 01, 2026 · 11:09 PM',
    );
    expect(
      orderDisputeErrorMessage(Exception('  ')),
      'Failed to submit dispute.',
    );
    expect(
      orderDisputeErrorMessage(Exception('Connection failed')),
      'Connection failed',
    );
  });
}

Future<void> _open(
  WidgetTester tester, {
  OrderDispute? dispute,
  SubmitOrderDispute? onSubmit,
}) async {
  tester.view.physicalSize = const Size(800, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final order = PlacedOrder(
    id: 'ORD-42',
    status: PlacedOrderStatus.delivered,
    placedAt: DateTime(2026, 9, 20),
    deliveryAddress: 'Test address',
    phoneNumber: '09123456789',
    items: const [],
    dispute: dispute,
  );
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showOrderDisputeSheet(
              context,
              order: order,
              onSubmitDispute: onSubmit ?? _noop,
            ),
            child: const Text('Open dispute'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open dispute'));
  await tester.pumpAndSettle();
}

Future<void> _noop({
  required String orderId,
  required OrderDisputeCategory category,
  required String reason,
  required OrderDisputeResolution requestedResolution,
}) async {}
