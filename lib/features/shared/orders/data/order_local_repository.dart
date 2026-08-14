import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:agresell_app/features/shared/orders/data/order_json_codec.dart';
import 'package:agresell_app/features/shared/orders/data/order_repository.dart';
import 'package:agresell_app/features/shared/orders/domain/order_feedback.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

class OrderLocalRepository
    implements OrderRepository, FarmerOrderCancellationRepository {
  OrderLocalRepository({this.preferences});

  static const _keyPrefix = 'orders.local.v1.';
  final SharedPreferences? preferences;

  @override
  Future<List<PlacedOrder>> load(String accountId) async {
    final encoded = (await _instance).getString('$_keyPrefix$accountId');
    if (encoded == null || encoded.isEmpty) return const [];

    try {
      return OrderJsonCodec.decodeOrders(jsonDecode(encoded));
    } on Object {
      return const [];
    }
  }

  @override
  Future<void> cancelFarmerOrder({
    required String accountId,
    required String orderId,
    required String reason,
  }) async {
    final orders = (await load(accountId)).toList();
    final index = orders.indexWhere((order) => order.id == orderId);
    if (index == -1) throw StateError('The order was not found.');
    final order = orders[index];
    if (!order.status.canFarmerCancel) {
      throw StateError('This order can no longer be cancelled.');
    }
    final cleanReason = reason.trim();
    if (cleanReason.isEmpty) {
      throw StateError('Select a cancellation reason.');
    }
    final paymentStatus = order.payment.status == OrderPaymentStatus.verified
        ? OrderPaymentStatus.refundRequired
        : OrderPaymentStatus.cancelled;
    orders[index] = order.copyWith(
      status: PlacedOrderStatus.cancelled,
      payment: order.payment.copyWith(status: paymentStatus),
      cancellationReason: cleanReason,
      cancelledBy: 'farmer',
      cancelledAt: DateTime.now(),
    );
    await save(accountId, orders);
  }

  @override
  Future<void> save(String accountId, Iterable<PlacedOrder> orders) async {
    final encoded = jsonEncode(OrderJsonCodec.encodeOrders(orders));
    final saved = await (await _instance).setString(
      '$_keyPrefix$accountId',
      encoded,
    );
    if (!saved) {
      throw StateError('The order could not be saved on this device.');
    }
  }

  @override
  Future<void> submitFeedback({
    required String accountId,
    required String orderId,
    required String productId,
    int? productRating,
    required String productComment,
    int? riderRating,
    String riderComment = '',
  }) async {
    final orders = (await load(accountId)).toList();
    final orderIndex = orders.indexWhere((order) => order.id == orderId);
    if (orderIndex == -1 ||
        orders[orderIndex].status != PlacedOrderStatus.delivered) {
      throw StateError('Only a delivered purchase can be reviewed.');
    }
    final order = orders[orderIndex];
    final itemIndex = order.items.indexWhere(
      (item) => item.productId == productId,
    );
    final items = [...order.items];
    OrderFeedback? feedback;
    if (productRating != null) {
      if (itemIndex == -1)
        throw StateError('You did not purchase this product.');
      if (order.items[itemIndex].feedback != null || order.isRated) {
        throw StateError('This purchased item has already been reviewed.');
      }
      feedback = OrderFeedback(
        rating: productRating,
        comment: productComment.trim(),
        submittedAt: DateTime.now().toUtc(),
      );
      items[itemIndex] = items[itemIndex].copyWith(feedback: feedback);
    }
    final allRated = items.every((item) => item.feedback != null);
    orders[orderIndex] = order.copyWith(
      items: items,
      isRated: allRated,
      feedback: allRated ? feedback ?? order.feedback : order.feedback,
      riderRated: riderRating == null ? order.riderRated : true,
    );
    await save(accountId, orders);
  }

  @override
  Future<void> createOrders({
    required String accountId,
    required Iterable<PlacedOrder> newOrders,
    required Iterable<PlacedOrder> currentOrders,
  }) => save(accountId, currentOrders);

  @override
  Future<void> markReadyForPickup({
    required String accountId,
    required String orderId,
  }) async {
    final orders = (await load(accountId)).toList();
    final index = orders.indexWhere((order) => order.id == orderId);
    if (index == -1) {
      throw StateError('The order was not found on this device.');
    }
    if (orders[index].status != PlacedOrderStatus.preparing) {
      throw StateError('Only a preparing order can be marked ready.');
    }
    orders[index] = orders[index].copyWith(
      status: PlacedOrderStatus.readyForPickup,
    );
    await save(accountId, orders);
  }

  @override
  Future<void> reviewGcashPayment({
    required String accountId,
    required String orderId,
    required bool approved,
  }) async {}

  @override
  Future<void> resubmitGcashReference({
    required String accountId,
    required String orderId,
    required String reference,
  }) async {}

  @override
  Future<void> recordGcashRefund({
    required String accountId,
    required String orderId,
    required String reference,
  }) async {}

  Future<SharedPreferences> get _instance async =>
      preferences ?? await SharedPreferences.getInstance();
}
