import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/core/widgets/app_snack_bar_panel.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';

import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_order_workflow_card.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'package:agresell_app/features/shared/orders/presentation/widgets/order_acceptance_deadline_card.dart';

void main() {
  for (final audience in OrderDeadlineAudience.values) {
    testWidgets('$audience sees a shared compact acceptance message', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final order = _order(
        expiresAt: DateTime.now().add(const Duration(hours: 2, minutes: 5)),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: OrderAcceptanceDeadlineCard(
                order: order,
                audience: audience,
              ),
            ),
          ),
        ),
      );

      expect(find.textContaining('left'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('left')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('order-deadline-info')));
      await tester.pumpAndSettle();
      expect(
        find.textContaining(
          audience == OrderDeadlineAudience.buyer
              ? 'Waiting for the farmer to respond.'
              : 'Accept the order before this time.',
        ),
        findsOneWidget,
      );
      expect(find.byType(AppSnackBarPanel), findsOneWidget);
      final panel = find
          .descendant(
            of: find.byType(AppSnackBarPanel),
            matching: find.byType(Material),
          )
          .first;
      expect(tester.getTopLeft(panel).dx, 12);
      expect(tester.getBottomRight(panel).dx, 308);
      expect(tester.getSize(panel).height, lessThan(180));
      expect(
        tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor,
        Colors.transparent,
      );
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(AppSnackBarPanel), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('farmer reviews payment without restoring an expired order', (
    tester,
  ) async {
    final order = _order(
      expiresAt: DateTime.now().subtract(const Duration(minutes: 2)),
      expiredAt: DateTime.now().subtract(const Duration(minutes: 1)),
      payment: const OrderPayment(
        method: OrderPaymentMethod.gcash,
        status: OrderPaymentStatus.paymentReviewRequired,
        transactionReference: '1234567890123',
      ),
    );
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: FarmerOrderWorkflowCard(
              order: order,
              controller: OrderController.instance,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Expired'), findsOneWidget);
    expect(find.text('Deadline expired'), findsOneWidget);
    expect(find.text('Payment review required'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);
    expect(find.text('Accept order'), findsNothing);

    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    expect(find.text('Review expired GCash payment'), findsOneWidget);
    expect(find.text('Received'), findsOneWidget);
    expect(find.textContaining('will not restore'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

PlacedOrder _order({
  required DateTime expiresAt,
  DateTime? expiredAt,
  OrderPayment payment = const OrderPayment.cashOnDelivery(),
}) => PlacedOrder(
  id: 'ORD-DEADLINE-F1',
  status: expiredAt == null
      ? PlacedOrderStatus.toShip
      : PlacedOrderStatus.cancelled,
  placedAt: DateTime.now().subtract(const Duration(hours: 1)),
  deliveryAddress: 'Malaybalay City, Bukidnon',
  phoneNumber: '09171234567',
  acceptanceExpiresAt: expiresAt,
  acceptanceExpiredAt: expiredAt,
  payment: payment,
  items: const [
    PlacedOrderItem(
      productId: '1',
      productName: 'Fresh tomatoes',
      image: 'assets/images/vege.jpeg',
      sellerName: 'Test Farmer',
      pricePerKg: 50,
      unit: 'kg',
      quantity: 2,
    ),
  ],
);
