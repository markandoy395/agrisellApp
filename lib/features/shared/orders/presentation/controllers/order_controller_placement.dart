part of 'order_controller.dart';

extension OrderControllerPlacement on OrderController {
  Future<PlacedOrder?> placeToShipOrder({
    required Iterable<BasketCartItem> items,
    required String deliveryAddress,
    required String phoneNumber,
    double? deliveryLatitude,
    double? deliveryLongitude,
    OrderPayment payment = const OrderPayment.cashOnDelivery(),
  }) async {
    final orders = await placeToShipOrders(
      items: items,
      deliveryAddress: deliveryAddress,
      phoneNumber: phoneNumber,
      deliveryLatitude: deliveryLatitude,
      deliveryLongitude: deliveryLongitude,
      payment: payment,
    );
    return orders.isEmpty ? null : orders.first;
  }

  Future<List<PlacedOrder>> placeToShipOrders({
    required Iterable<BasketCartItem> items,
    required String deliveryAddress,
    required String phoneNumber,
    double? deliveryLatitude,
    double? deliveryLongitude,
    OrderPayment payment = const OrderPayment.cashOnDelivery(),
  }) => _runOrderAction(
    'checkout',
    () => _placeToShipOrders(
      items: List.of(items),
      deliveryAddress: deliveryAddress,
      phoneNumber: phoneNumber,
      deliveryLatitude: deliveryLatitude,
      deliveryLongitude: deliveryLongitude,
      payment: payment,
    ),
  );

  Future<List<PlacedOrder>> _placeToShipOrders({
    required Iterable<BasketCartItem> items,
    required String deliveryAddress,
    required String phoneNumber,
    double? deliveryLatitude,
    double? deliveryLongitude,
    required OrderPayment payment,
  }) async {
    final account = _accountId;
    final generation = _accountGeneration;
    final groups = <String, List<BasketCartItem>>{};
    for (final item in items) {
      groups.putIfAbsent(_sellerKey(item), () => []).add(item);
    }
    if (groups.isEmpty) return const [];
    if (payment.method == OrderPaymentMethod.gcash && groups.length > 1) {
      throw ArgumentError('GCash checkout must contain one farmer.');
    }

    final placedAt = DateTime.now();
    final checkoutId = 'ORD-${placedAt.microsecondsSinceEpoch}';
    var newOrders = groups.entries
        .map((entry) {
          return PlacedOrder(
            id: '$checkoutId-${entry.key}',
            status: PlacedOrderStatus.toShip,
            placedAt: placedAt,
            deliveryAddress: deliveryAddress,
            phoneNumber: phoneNumber,
            deliveryLatitude: deliveryLatitude,
            deliveryLongitude: deliveryLongitude,
            acceptanceExpiresAt: OrderAcceptancePolicy.deadlineFor(placedAt),
            payment: payment,
            items: entry.value
                .map(PlacedOrderItem.fromBasketItem)
                .toList(growable: false),
          );
        })
        .toList(growable: false);

    CheckoutAttempt? attempt;
    if (account != null) {
      attempt = await _checkoutAttempts.prepare(account, newOrders);
      if (_disposed || generation != _accountGeneration) {
        throw StateError('The checkout account changed.');
      }
      newOrders = attempt.orders;
      if (attempt.operation.isRetry) {
        final saved = await _repository.load(account);
        if (_disposed || generation != _accountGeneration) {
          throw StateError('The checkout account changed.');
        }
        final ids = newOrders.map((order) => order.id).toSet();
        final confirmed = saved
            .where((order) => ids.contains(order.id))
            .toList();
        if (confirmed.length == ids.length) {
          _orders.removeWhere((order) => ids.contains(order.id));
          _orders.insertAll(0, confirmed);
          await _checkoutAttempts.complete(attempt);
          _commitChange(persist: false);
          return confirmed;
        }
      }
    }

    final previousNotificationCount = _orderNotifications.length;
    _orders.insertAll(0, newOrders);
    for (final order in newOrders.reversed) {
      _addOrderNotification(
        order: order,
        title: 'New order needs your acceptance',
        description:
            '${order.title} was placed. Review it, accept it, then prepare it for rider pickup.',
        visibleTo: const {AuthRole.farmer},
      );
    }
    _commitChange(persist: false);
    try {
      await _persistNewOrders(newOrders);
      if (attempt != null) await _checkoutAttempts.complete(attempt);
    } on Object catch (error) {
      if (attempt != null &&
          error is OrderPlacementException &&
          error.definitivelyRejected) {
        await _checkoutAttempts.complete(attempt);
      }
      if (_disposed || generation != _accountGeneration) rethrow;
      _orders.removeWhere(newOrders.contains);
      final addedNotificationCount =
          _orderNotifications.length - previousNotificationCount;
      if (addedNotificationCount > 0) {
        _orderNotifications.removeRange(0, addedNotificationCount);
      }
      _commitChange(persist: false);
      rethrow;
    }
    if (_disposed || generation != _accountGeneration) {
      throw StateError('The checkout account changed.');
    }
    return List<PlacedOrder>.unmodifiable(newOrders);
  }

  Future<void> _persistNewOrders(Iterable<PlacedOrder> newOrders) {
    final accountId = _accountId;
    final generation = _accountGeneration;
    if (accountId == null) return Future<void>.value();
    final previousWrite = _pendingPersistence;
    final additions = List<PlacedOrder>.of(newOrders);
    final snapshot = List<PlacedOrder>.of(_orders);
    final write = () async {
      try {
        await previousWrite;
      } on Object {
        // A new checkout must not be blocked by an older stale snapshot.
      }
      if (_disposed || generation != _accountGeneration) {
        throw StateError('The checkout account changed.');
      }
      await _repository.createOrders(
        accountId: accountId,
        newOrders: additions,
        currentOrders: snapshot,
      );
    }();
    _pendingPersistence = write;
    return write;
  }

  String _sellerKey(BasketCartItem item) {
    final farmId = item.farmId;
    if (farmId != null && farmId > 0) return 'F$farmId';
    final identity = '${item.sellerName}\u0000${item.sellerLocation}';
    var hash = 0x811c9dc5;
    for (final value in identity.codeUnits) {
      hash = ((hash ^ value) * 0x01000193) & 0x7fffffff;
    }
    return 'S${hash.toRadixString(36)}';
  }
}
