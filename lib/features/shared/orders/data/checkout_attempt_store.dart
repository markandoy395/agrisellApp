import 'package:agresell_app/core/services/pending_operation_store.dart';
import 'order_json_codec.dart';
import '../domain/placed_order.dart';

class CheckoutAttemptStore {
  CheckoutAttemptStore({PendingOperationStore? store})
    : _store = store ?? PendingOperationStore();
  final PendingOperationStore _store;

  Future<CheckoutAttempt> prepare(
    String account,
    List<PlacedOrder> orders,
  ) async {
    final payload = OrderJsonCodec.encodeOrders(orders);
    for (final order in payload) {
      order.remove('id');
      order.remove('placedAt');
      order.remove('acceptanceExpiresAt');
    }
    final operation = await _store.prepare(
      account,
      'checkout',
      payload,
      singlePending: true,
    );
    final stableOrders = OrderJsonCodec.encodeOrders(orders);
    for (var i = 0; i < orders.length; i++) {
      final seller = orders[i].id.split('-').last;
      final lifetime = orders[i].acceptanceExpiresAt?.difference(
        orders[i].placedAt,
      );
      stableOrders[i]['id'] = 'ORD-${operation.id}-$seller';
      stableOrders[i]['placedAt'] = operation.createdAt.toIso8601String();
      if (lifetime != null) {
        stableOrders[i]['acceptanceExpiresAt'] = operation.createdAt
            .add(lifetime)
            .toIso8601String();
      }
    }
    return CheckoutAttempt(
      operation,
      OrderJsonCodec.decodeOrders(stableOrders),
    );
  }

  Future<void> complete(CheckoutAttempt attempt) =>
      _store.complete(attempt.operation);
}

class CheckoutAttempt {
  const CheckoutAttempt(this.operation, this.orders);
  final PendingOperation operation;
  final List<PlacedOrder> orders;
}
