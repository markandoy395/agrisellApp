part of 'order_controller.dart';

extension OrderControllerPersistence on OrderController {
  void clear() {
    _accountGeneration++;
    _loadGeneration++;
    if (_orders.isEmpty &&
        _orderNotifications.isEmpty &&
        _readNotificationIds.isEmpty) {
      return;
    }
    _orders.clear();
    _orderNotifications.clear();
    _readNotificationIds.clear();
    _commitChange();
  }

  Future<void> loadForAccount(String accountId) async {
    final generation = ++_loadGeneration;
    if (_accountId != accountId) {
      _accountGeneration++;
      _orders.clear();
      _orderNotifications.clear();
      _readNotificationIds.clear();
      _commitChange(persist: false);
    }
    _accountId = accountId;
    try {
      await _pendingPersistence;
    } on Object {
      // A fresh load can still recover the last successfully saved snapshot.
    }
    if (generation != _loadGeneration || _accountId != accountId) return;
    await _operations.serialize(('orders', accountId), () async {
      try {
        await _pendingPersistence;
      } on Object {
        // The server snapshot can reconcile a failed prior mutation.
      }
      if (_disposed || generation != _loadGeneration || _accountId != accountId)
        return;
      final savedOrders = await _repository.load(accountId);
      if (_disposed || generation != _loadGeneration || _accountId != accountId)
        return;
      _orders
        ..clear()
        ..addAll(savedOrders);
      _orderNotifications.clear();
      _readNotificationIds.clear();
      _commitChange(persist: false);
    });
  }

  Future<void> reload() async {
    final accountId = _accountId;
    if (accountId != null) await loadForAccount(accountId);
  }

  void unload() {
    _accountGeneration++;
    _loadGeneration++;
    _accountId = null;
    _orders.clear();
    _orderNotifications.clear();
    _readNotificationIds.clear();
    _commitChange(persist: false);
  }

  Future<void> _persistOrdersSilently() async {
    try {
      await _persistOrders();
    } on Object {
      // The next explicit order placement will surface storage failures.
    }
  }

  Future<void> _persistOrders() {
    final accountId = _accountId;
    final generation = _accountGeneration;
    if (accountId == null) return Future<void>.value();
    final previousWrite = _pendingPersistence;
    final snapshot = List<PlacedOrder>.of(_orders);
    final write = () async {
      try {
        await previousWrite;
      } on Object {
        // Continue with the newest complete order snapshot.
      }
      if (_disposed || generation != _accountGeneration) {
        throw StateError('The order account changed.');
      }
      await _repository.save(accountId, snapshot);
    }();
    _pendingPersistence = write;
    return write;
  }
}
