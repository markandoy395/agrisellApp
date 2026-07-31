part of 'rider_offline_queue_phase9_test.dart';

Future<OfflineDeliveryAction> _add(
  RiderOfflineActionQueue queue,
  DateTime at, {
  String? key,
  OfflineDeliveryActionType type =
      OfflineDeliveryActionType.deliveryStatusUpdate,
  int? maxRetries,
}) => queue.add(
  riderId: 'rider-1',
  deliveryId: 'delivery-1',
  type: type,
  payload: const {'status': 'going_to_pickup'},
  originalTimestamp: at,
  idempotencyKey: key,
  maxRetries: maxRetries,
);

class _MemoryQueueRepository implements OfflineQueueRepository {
  final Map<String, List<OfflineDeliveryAction>> _items = {};

  @override
  Future<void> enqueue(OfflineDeliveryAction action) async {
    _items.putIfAbsent(action.riderId, () => []).add(action);
  }

  @override
  Future<List<OfflineDeliveryAction>> loadAll(String riderId) async =>
      List.of(_items[riderId] ?? const []);

  @override
  Future<List<OfflineDeliveryAction>> loadPending(String riderId) async =>
      loadAll(riderId);

  @override
  Future<void> remove(String actionId) async {
    for (final actions in _items.values) {
      actions.removeWhere((action) => action.localId == actionId);
    }
  }

  @override
  Future<void> replace(OfflineDeliveryAction action) async {
    final actions = _items.putIfAbsent(action.riderId, () => []);
    actions.removeWhere((item) => item.localId == action.localId);
    actions.add(action);
  }

  @override
  Future<void> replaceAll(
    String riderId,
    List<OfflineDeliveryAction> actions,
  ) async {
    _items[riderId] = List.of(actions);
  }
}

class _ScriptedRemote implements RiderOfflineActionRemote {
  final Map<String, OfflineActionSyncResult> results = {};
  final List<String> sent = [];

  @override
  Future<OfflineActionSyncResult> synchronize(
    OfflineDeliveryAction action,
  ) async {
    sent.add(action.idempotencyKey);
    return results[action.idempotencyKey] ??
        const OfflineActionSyncResult.acknowledged();
  }
}
