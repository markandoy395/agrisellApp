part of 'order_controller.dart';

extension OrderControllerPayments on OrderController {
  Future<void> _recordGcashRefund({
    required String orderId,
    required String reference,
  }) async {
    final generation = _accountGeneration;
    final normalized = reference.trim();
    if (!RegExp(r'^[A-Za-z0-9 _-]{6,40}$').hasMatch(normalized)) {
      throw ArgumentError('Enter a valid refund reference number.');
    }
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1 ||
        _orders[index].payment.status != OrderPaymentStatus.refundRequired) {
      throw StateError('This order does not have a pending refund.');
    }
    final accountId = _accountId;
    if (accountId != null) {
      await _repository.recordGcashRefund(
        accountId: accountId,
        orderId: orderId,
        reference: normalized,
      );
    }
    if (_disposed || generation != _accountGeneration) return;
    _orders[index] = _orders[index].copyWith(
      payment: _orders[index].payment.copyWith(
        status: OrderPaymentStatus.refunded,
        refundReference: normalized,
      ),
    );
    _commitChange();
  }

  Future<void> _resubmitGcashReference({
    required String orderId,
    required String reference,
  }) async {
    final generation = _accountGeneration;
    final normalized = OrderPayment.normalizeGcashReference(reference);
    if (!OrderPayment.isValidGcashReference(normalized)) {
      throw ArgumentError('Enter the 13-digit GCash reference number.');
    }
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1 ||
        _orders[index].payment.method != OrderPaymentMethod.gcash ||
        _orders[index].payment.status != OrderPaymentStatus.rejected) {
      throw StateError('This payment does not need a replacement reference.');
    }
    final accountId = _accountId;
    if (accountId != null) {
      await _repository.resubmitGcashReference(
        accountId: accountId,
        orderId: orderId,
        reference: normalized,
      );
    }
    if (_disposed || generation != _accountGeneration) return;
    _orders[index] = _orders[index].copyWith(
      payment: OrderPayment.gcash(normalized),
    );
    _commitChange();
  }

  Future<void> _reviewGcashPayment({
    required String orderId,
    required bool approved,
  }) async {
    final generation = _accountGeneration;
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1 || !_orders[index].payment.needsFarmerReview) {
      throw StateError('This GCash reference is not awaiting review.');
    }
    final accountId = _accountId;
    if (accountId != null) {
      await _repository.reviewGcashPayment(
        accountId: accountId,
        orderId: orderId,
        approved: approved,
      );
    }

    if (_disposed || generation != _accountGeneration) return;
    final status = _orders[index].isExpired
        ? approved
              ? OrderPaymentStatus.refundRequired
              : OrderPaymentStatus.cancelled
        : approved
        ? OrderPaymentStatus.verified
        : OrderPaymentStatus.rejected;
    _orders[index] = _orders[index].copyWith(
      payment: _orders[index].payment.copyWith(status: status),
    );
    _commitChange();
  }
}
