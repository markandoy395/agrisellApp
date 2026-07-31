import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_foundation_repositories.dart';
import 'package:agresell_app/features/rider/deliveries/domain/offline_delivery_action.dart';

class MemoryOfflineQueueRepository implements OfflineQueueRepository {
  final Map<String, List<OfflineDeliveryAction>> _items = {};

  @override
  Future<void> enqueue(OfflineDeliveryAction action) async {
    _items.putIfAbsent(action.riderId, () => []).add(action);
  }

  @override
  Future<List<OfflineDeliveryAction>> loadAll(String riderId) async =>
      List.of(_items[riderId] ?? const []);

  @override
  Future<List<OfflineDeliveryAction>> loadPending(String riderId) =>
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
