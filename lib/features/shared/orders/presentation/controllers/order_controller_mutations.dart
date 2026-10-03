part of 'order_controller.dart';

extension OrderControllerMutations on OrderController {
  Future<void> acceptOrder(String orderId) {
    final order = _orders.where((item) => item.id == orderId).firstOrNull;
    if (order?.isAcceptanceOverdue ?? false) {
      return Future<void>.error(
        StateError('The farmer acceptance deadline has passed.'),
      );
    }
    if (order != null && !order.payment.allowsOrderAcceptance) {
      return Future<void>.error(
        StateError('Verify the GCash reference before accepting this order.'),
      );
    }
    return _changeFarmerOrderStatus(
      orderId: orderId,
      from: PlacedOrderStatus.toShip,
      to: PlacedOrderStatus.preparing,
      title: 'Order accepted by the farmer',
      description: 'Your order is now being prepared by the farmer.',
      visibleTo: const {AuthRole.buyer},
    );
  }

  Future<void> markReadyForPickup(String orderId) async {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1 || _orders[index].status != PlacedOrderStatus.preparing) {
      return;
    }
    final previousOrder = _orders[index];
    final previousNotificationCount = _orderNotifications.length;
    _orders[index] = previousOrder.copyWith(
      status: PlacedOrderStatus.readyForPickup,
    );
    _addOrderNotification(
      order: _orders[index],
      title: 'Order ready for rider pickup',
      description:
          'The farmer has finished preparing your order. A rider can now pick it up.',
      visibleTo: const {AuthRole.buyer},
    );
    _commitChange(persist: false);
    try {
      await _persistReadyForPickup(orderId);
    } on Object {
      _orders[index] = previousOrder;
      if (_orderNotifications.length > previousNotificationCount) {
        _orderNotifications.removeRange(
          0,
          _orderNotifications.length - previousNotificationCount,
        );
      }
      _commitChange(persist: false);
      rethrow;
    }
  }

  Future<void> _persistReadyForPickup(String orderId) {
    final accountId = _accountId;
    if (accountId == null) return Future<void>.value();
    final previousWrite = _pendingPersistence;
    final write = () async {
      try {
        await previousWrite;
      } on Object {
        // Continue with the explicit, server-authorized transition.
      }
      await _repository.markReadyForPickup(
        accountId: accountId,
        orderId: orderId,
      );
    }();
    _pendingPersistence = write;
    return write;
  }

  Future<void> cancelOrder(String orderId) => _cancelBuyerOrder(orderId);

  Future<void> cancelFarmerOrder(String orderId, String reason) =>
      _cancelFarmerOrder(orderId, reason);

  Future<void> _changeFarmerOrderStatus({
    required String orderId,
    required PlacedOrderStatus from,
    required PlacedOrderStatus to,
    required String title,
    required String description,
    Set<AuthRole> visibleTo = const {AuthRole.buyer, AuthRole.farmer},
  }) async {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1 || _orders[index].status != from) return;
    final previousOrder = _orders[index];
    final previousNotificationCount = _orderNotifications.length;
    _orders[index] = _orders[index].copyWith(status: to);
    _addOrderNotification(
      order: _orders[index],
      title: title,
      description: description,
      visibleTo: visibleTo,
    );
    _commitChange(persist: false);
    try {
      await _persistOrders();
    } on Object {
      _orders[index] = previousOrder;
      if (_orderNotifications.length > previousNotificationCount) {
        _orderNotifications.removeRange(
          0,
          _orderNotifications.length - previousNotificationCount,
        );
      }
      _commitChange(persist: false);
      rethrow;
    }
  }

  Future<void> reportOrderDispute({
    required String orderId,
    required OrderDisputeCategory category,
    required String reason,
    required OrderDisputeResolution requestedResolution,
  }) async {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1) return;
    final cleanReason = reason.trim();
    if (cleanReason.isEmpty) {
      throw StateError('Please explain the issue with your delivered produce.');
    }
    final previousOrder = _orders[index];
    if (!previousOrder.canDispute) {
      throw StateError('This order cannot be disputed.');
    }
    final accountId = _accountId;
    if (accountId == null)
      throw StateError('Sign in before reporting an issue.');

    final dispute = OrderDispute(
      status: OrderDisputeStatus.pending,
      category: category,
      reason: cleanReason,
      requestedResolution: requestedResolution,
      submittedAt: DateTime.now(),
    );

    await _repository.reportOrderDispute(
      accountId: accountId,
      orderId: orderId,
      category: category.value,
      reason: cleanReason,
      requestedResolution: requestedResolution.value,
    );

    _orders[index] = previousOrder.copyWith(dispute: dispute);
    _addOrderNotification(
      order: _orders[index],
      title: 'Dispute submitted',
      description:
          'Your dispute for "${_orders[index].title}" was submitted for review.',
      visibleTo: const {AuthRole.buyer},
    );
    _commitChange(persist: false);
  }
}
