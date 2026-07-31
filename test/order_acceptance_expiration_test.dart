import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agresell_app/features/shared/orders/data/order_json_codec.dart';
import 'package:agresell_app/features/shared/orders/data/order_local_repository.dart';
import 'package:agresell_app/features/shared/orders/data/order_snapshot_merger.dart';
import 'package:agresell_app/features/shared/orders/domain/order_acceptance_policy.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';

void main() {
  test('acceptance policy pauses outside marketplace hours', () {
    expect(
      OrderAcceptancePolicy.deadlineFor(DateTime(2026, 7, 30, 8)),
      DateTime(2026, 7, 30, 12),
    );
    expect(
      OrderAcceptancePolicy.deadlineFor(DateTime(2026, 7, 30, 18)),
      DateTime(2026, 7, 31, 8),
    );
    expect(
      OrderAcceptancePolicy.deadlineFor(DateTime(2026, 7, 30, 21)),
      DateTime(2026, 7, 31, 10),
    );
  });

  test('expiration snapshot closes the order and preserves evidence', () {
    final merged = OrderSnapshotMerger.merge(
      [OrderJsonCodec.encodeOrder(_order())],
      expirations: [
        {
          'orderId': 'ORD-EXPIRED',
          'acceptanceExpiresAt': '2026-07-30T08:00:00Z',
          'acceptanceExpiredAt': '2026-07-30T08:01:00Z',
        },
      ],
    );
    final restored = OrderJsonCodec.decodeOrder(merged.single)!;

    expect(restored.status, PlacedOrderStatus.cancelled);
    expect(restored.isExpired, isTrue);
    expect(restored.acceptanceExpiresAt, isNotNull);
  });

  test(
    'expired unverified GCash becomes a refund only when received',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = OrderLocalRepository(preferences: preferences);
      final expired = _order(
        payment: const OrderPayment(
          method: OrderPaymentMethod.gcash,
          status: OrderPaymentStatus.paymentReviewRequired,
          transactionReference: '1234567890123',
        ),
        expiredAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );
      await repository.save('farmer-1', [expired]);
      final controller = OrderController(repository: repository);
      await controller.loadForAccount('farmer-1');

      await controller.reviewGcashPayment(orderId: expired.id, approved: true);

      expect(
        controller.orders.single.payment.status,
        OrderPaymentStatus.refundRequired,
      );
      expect(controller.orders.single.isExpired, isTrue);
    },
  );

  test('overdue order cannot be accepted from a stale client', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = OrderLocalRepository(preferences: preferences);
    final overdue = _order(
      expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
    );
    await repository.save('farmer-1', [overdue]);
    final controller = OrderController(repository: repository);
    await controller.loadForAccount('farmer-1');

    await expectLater(controller.acceptOrder(overdue.id), throwsStateError);
  });

  test('expired cash order is not an active farmer reservation', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = OrderLocalRepository(preferences: preferences);
    final expired = _order(
      expiredAt: DateTime.now().subtract(const Duration(minutes: 1)),
    );
    await repository.save('farmer-1', [expired]);
    final controller = OrderController(repository: repository);

    await controller.loadForAccount('farmer-1');

    expect(controller.activeFarmerReservationCount, 0);
  });
}

PlacedOrder _order({
  OrderPayment payment = const OrderPayment.cashOnDelivery(),
  DateTime? expiresAt,
  DateTime? expiredAt,
}) => PlacedOrder(
  id: 'ORD-EXPIRED',
  status: expiredAt == null
      ? PlacedOrderStatus.toShip
      : PlacedOrderStatus.cancelled,
  placedAt: DateTime(2026, 7, 30, 8),
  deliveryAddress: 'Test address',
  phoneNumber: '09171234567',
  acceptanceExpiresAt: expiresAt ?? DateTime(2026, 7, 30, 12),
  acceptanceExpiredAt: expiredAt,
  payment: payment,
  items: const [
    PlacedOrderItem(
      productId: '1',
      productName: 'Tomato',
      image: 'assets/images/vege.jpeg',
      sellerName: 'Test Farmer',
      pricePerKg: 50,
      unit: 'kg',
      quantity: 2,
    ),
  ],
);
