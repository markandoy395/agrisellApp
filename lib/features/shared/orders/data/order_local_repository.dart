import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:agresell_app/features/shared/orders/data/order_json_codec.dart';
import 'package:agresell_app/features/shared/orders/data/order_repository.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

class OrderLocalRepository implements OrderRepository {
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
