part of 'order_controller.dart';

extension OrderControllerPersistence on OrderController {
  void clear() {
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
    _accountId = accountId;
    try {
      await _pendingPersistence;
    } on Object {
      // A fresh load can still recover the last successfully saved snapshot.
    }
    if (generation != _loadGeneration || _accountId != accountId) return;
    final savedOrders = await _repository.load(accountId);
    if (generation != _loadGeneration || _accountId != accountId) return;
    _orders
      ..clear()
      ..addAll(savedOrders);
    _orderNotifications.clear();
    _readNotificationIds.clear();
    _commitChange(persist: false);
  }

  Future<void> reload() async {
    final accountId = _accountId;
    if (accountId != null) await loadForAccount(accountId);
  }

  void unload() {
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
    if (accountId == null) return Future<void>.value();
    final previousWrite = _pendingPersistence;
    final snapshot = List<PlacedOrder>.of(_orders);
    final write = () async {
      try {
        await previousWrite;
      } on Object {
        // Continue with the newest complete order snapshot.
      }
      await _repository.save(accountId, snapshot);
    }();
    _pendingPersistence = write;
    return write;
  }
}
