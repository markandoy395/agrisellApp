import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_order_cancellation_dialog.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_order_workflow_card.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';

void main() {
  testWidgets('confirmation requires a selected cancellation reason', (
    tester,
  ) async {
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => FilledButton(
            onPressed: () async {
              result = await showFarmerOrderCancellationDialog(context);
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Cancel Order?'), findsOneWidget);
    expect(find.text('This action cannot be undone.'), findsOneWidget);
    expect(find.text('Cancellation Reason:'), findsOneWidget);
    expect(find.text('Keep Order'), findsOneWidget);
    final confirm = tester.widget<FilledButton>(
      find.byKey(const ValueKey('confirm-farmer-order-cancellation')),
    );
    expect(confirm.onPressed, isNull);

    await tester.tap(find.byKey(const ValueKey('farmer-cancellation-reason')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Farm emergency').last);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('confirm-farmer-order-cancellation')),
    );
    await tester.pumpAndSettle();

    expect(result, 'Farm emergency');
  });

  testWidgets('cancel action appears only for farmer-cancellable statuses', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FarmerOrderWorkflowCard(
            order: _order(PlacedOrderStatus.readyForPickup),
            controller: OrderController(),
            onCancelOrder: () async {},
          ),
        ),
      ),
    );
    expect(
      find.byKey(const ValueKey('farmer-cancel-order-button')),
      findsOneWidget,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FarmerOrderWorkflowCard(
            order: _order(PlacedOrderStatus.shipping),
            controller: OrderController(),
            onCancelOrder: () async {},
          ),
        ),
      ),
    );
    expect(
      find.byKey(const ValueKey('farmer-cancel-order-button')),
      findsNothing,
    );
  });
}

PlacedOrder _order(PlacedOrderStatus status) => PlacedOrder(
  id: 'ORDER-1',
  status: status,
  placedAt: DateTime(2026, 8, 11),
  deliveryAddress: 'Buyer address',
  phoneNumber: '09123456789',
  items: const [],
);
