import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

abstract interface class OrderRepository {
  Future<List<PlacedOrder>> load(String accountId);

  Future<void> save(String accountId, Iterable<PlacedOrder> orders);

  Future<void> markReadyForPickup({
    required String accountId,
    required String orderId,
  });

  Future<void> reviewGcashPayment({
    required String accountId,
    required String orderId,
    required bool approved,
  });

  Future<void> resubmitGcashReference({
    required String accountId,
    required String orderId,
    required String reference,
  });

  Future<void> recordGcashRefund({
    required String accountId,
    required String orderId,
    required String reference,
  });
}

class OrderPlacementException implements Exception {
  const OrderPlacementException(this.message);

  final String message;

  @override
  String toString() => message;
}
