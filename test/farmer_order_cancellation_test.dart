import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/shared/orders/data/order_repository.dart';
import 'package:agresell_app/features/shared/orders/data/order_json_codec.dart';
import 'package:agresell_app/features/shared/orders/data/order_snapshot_merger.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';

void main() {
  test(
    'farmer cancellation records reason and updates payment state',
    () async {
      final repository = _CancellationRepository(
        _order(
          PlacedOrderStatus.readyForPickup,
          payment: const OrderPayment(
            method: OrderPaymentMethod.gcash,
            status: OrderPaymentStatus.verified,
          ),
        ),
      );
      final controller = OrderController(repository: repository);
      await controller.loadForAccount('farmer-1');

      await controller.cancelFarmerOrder('ORDER-1', 'Farm emergency');

      expect(repository.cancelledOrderId, 'ORDER-1');
      expect(repository.cancellationReason, 'Farm emergency');
      expect(controller.orders.single.status, PlacedOrderStatus.cancelled);
      expect(
        controller.orders.single.payment.status,
        OrderPaymentStatus.refundRequired,
      );
      expect(controller.orders.single.cancelledBy, 'farmer');
      expect(controller.orders.single.cancellationReason, 'Farm emergency');
      expect(controller.orders.single.cancelledAt, isNotNull);
    },
  );

  test('farmer cannot cancel shipping, completed, or cancelled orders', () {
    expect(PlacedOrderStatus.shipping.canFarmerCancel, isFalse);
    expect(PlacedOrderStatus.delivered.canFarmerCancel, isFalse);
    expect(PlacedOrderStatus.cancelled.canFarmerCancel, isFalse);
    expect(PlacedOrderStatus.toShip.canFarmerCancel, isTrue);
    expect(PlacedOrderStatus.preparing.canFarmerCancel, isTrue);
    expect(PlacedOrderStatus.readyForPickup.canFarmerCancel, isTrue);
  });

  test('shipping order does not call cancellation repository', () async {
    final repository = _CancellationRepository(
      _order(PlacedOrderStatus.shipping),
    );
    final controller = OrderController(repository: repository);
    await controller.loadForAccount('farmer-1');

    await controller.cancelFarmerOrder('ORDER-1', 'Out of stock');

    expect(repository.cancelledOrderId, isNull);
    expect(controller.orders.single.status, PlacedOrderStatus.shipping);
  });

  test('buyer and farmer snapshots retain cancellation audit details', () {
    final merged = OrderSnapshotMerger.merge(
      [OrderJsonCodec.encodeOrder(_order(PlacedOrderStatus.cancelled))],
      cancellations: [
        {
          'orderId': 'ORDER-1',
          'cancellationReason': 'Product unavailable',
          'cancelledBy': 'farmer',
          'cancelledAt': '2026-08-11T04:30:00Z',
        },
      ],
    );

    final decoded = OrderJsonCodec.decodeOrders(merged).single;
    expect(decoded.cancellationReason, 'Product unavailable');
    expect(decoded.cancelledBy, 'farmer');
    expect(decoded.cancelledAt, isNotNull);
  });
}

PlacedOrder _order(PlacedOrderStatus status, {OrderPayment? payment}) =>
    PlacedOrder(
      id: 'ORDER-1',
      status: status,
      placedAt: DateTime(2026, 8, 11),
      deliveryAddress: 'Buyer address',
      phoneNumber: '09123456789',
      items: const [],
      payment: payment,
    );

class _CancellationRepository
    implements OrderRepository, FarmerOrderCancellationRepository {
  _CancellationRepository(this.order);

  final PlacedOrder order;
  String? cancelledOrderId;
  String? cancellationReason;

  @override
  Future<void> cancelFarmerOrder({
    required String accountId,
    required String orderId,
    required String reason,
  }) async {
    cancelledOrderId = orderId;
    cancellationReason = reason;
  }

  @override
  Future<List<PlacedOrder>> load(String accountId) async => [order];

  @override
  Future<void> save(String accountId, Iterable<PlacedOrder> orders) async {}

  @override
  Future<void> createOrders({
    required String accountId,
    required Iterable<PlacedOrder> newOrders,
    required Iterable<PlacedOrder> currentOrders,
  }) async {}

  @override
  Future<void> markReadyForPickup({
    required String accountId,
    required String orderId,
  }) async {}

  @override
  Future<void> recordGcashRefund({
    required String accountId,
    required String orderId,
    required String reference,
  }) async {}

  @override
  Future<void> resubmitGcashReference({
    required String accountId,
    required String orderId,
    required String reference,
  }) async {}

  @override
  Future<void> reviewGcashPayment({
    required String accountId,
    required String orderId,
    required bool approved,
  }) async {}

  @override
  Future<void> submitFeedback({
    required String accountId,
    required String orderId,
    required String productId,
    int? productRating,
    required String productComment,
    int? riderRating,
    String riderComment = '',
  }) async {}

  @override
  Future<void> reportOrderDispute({
    required String accountId,
    required String orderId,
    required String category,
    required String reason,
    required String requestedResolution,
  }) async {}
}
