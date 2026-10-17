part of 'order_controller.dart';

extension _OrderControllerCancellations on OrderController {
  Future<void> _cancelBuyerOrder(String orderId) async {
    final generation = _accountGeneration;
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1 || !_orders[index].status.canCancel) return;
    final previousOrder = _orders[index];
    final previousNotificationCount = _orderNotifications.length;
    final cancelledPaymentStatus =
        previousOrder.payment.status == OrderPaymentStatus.verified
        ? OrderPaymentStatus.refundRequired
        : OrderPaymentStatus.cancelled;
    _orders[index] = _orders[index].copyWith(
      status: PlacedOrderStatus.cancelled,
      payment: previousOrder.payment.copyWith(status: cancelledPaymentStatus),
    );
    _addOrderNotification(
      order: _orders[index],
      title: 'Order cancelled',
      description: '${_orders[index].title} was cancelled before delivery.',
    );
    _commitChange(persist: false);
    try {
      await _persistOrders();
    } on Object {
      if (_disposed || generation != _accountGeneration) rethrow;
      _orders[index] = previousOrder;
      final addedCount = _orderNotifications.length - previousNotificationCount;
      if (addedCount > 0) _orderNotifications.removeRange(0, addedCount);
      _commitChange(persist: false);
      rethrow;
    }
  }

  Future<void> _cancelFarmerOrder(String orderId, String reason) async {
    final generation = _accountGeneration;
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1 || !_orders[index].status.canFarmerCancel) return;
    if (_repository is! FarmerOrderCancellationRepository) {
      throw StateError('Farmer order cancellation is unavailable.');
    }
    final repository = _repository as FarmerOrderCancellationRepository;
    final cleanReason = reason.trim();
    if (cleanReason.isEmpty) {
      throw StateError('Select a cancellation reason.');
    }
    final accountId = _accountId;
    if (accountId == null) throw StateError('Sign in before cancelling.');
    await repository.cancelFarmerOrder(
      accountId: accountId,
      orderId: orderId,
      reason: cleanReason,
    );
    if (_disposed || generation != _accountGeneration) return;
    final previousOrder = _orders[index];
    final cancelledPaymentStatus =
        previousOrder.payment.status == OrderPaymentStatus.verified
        ? OrderPaymentStatus.refundRequired
        : OrderPaymentStatus.cancelled;
    _orders[index] = previousOrder.copyWith(
      status: PlacedOrderStatus.cancelled,
      payment: previousOrder.payment.copyWith(status: cancelledPaymentStatus),
      cancellationReason: cleanReason,
      cancelledBy: 'farmer',
      cancelledAt: DateTime.now(),
    );
    _addOrderNotification(
      order: _orders[index],
      title: 'Order cancelled',
      description: '${_orders[index].title} was cancelled: $cleanReason.',
    );
    _commitChange(persist: false);
  }
}
