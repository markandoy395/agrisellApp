import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/deliveries/data/rider_offline_action_queue.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_offline_sync_engine.dart';
import 'package:agresell_app/features/rider/deliveries/domain/offline_delivery_action.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_offline_sync.dart';
import 'support/memory_offline_queue_repository.dart';

void main() {
  final now = DateTime.utc(2032, 1, 1);

  test('one delivery conflict does not block another delivery queue', () async {
    final queue = RiderOfflineActionQueue(
      repository: MemoryOfflineQueueRepository(),
      clock: () => now,
    );
    final remote = _BatchRemote();
    final engine = RiderOfflineSyncEngine(
      queue: queue,
      remote: remote,
      clock: () => now,
    );
    addTearDown(engine.dispose);
    await queue.initialize('rider-a');
    final first = await _add(queue, 'delivery-a', 'a-status');
    await _add(queue, 'delivery-a', 'a-proof', dependencyId: first.localId);
    await _add(queue, 'delivery-b', 'b-status');
    remote.results['a-status'] = OfflineActionSyncResult.conflict(
      OfflineActionConflict.deliveryCancelled,
      'Only delivery A was cancelled.',
    );

    await engine.synchronize();

    expect(remote.sent, ['a-status', 'b-status']);
    expect(
      queue.actions.map((item) => item.deliveryId),
      everyElement('delivery-a'),
    );
    expect(
      queue.actions.first.status,
      OfflineDeliveryActionStatus.requiresAttention,
    );
    expect(queue.actions.last.status, OfflineDeliveryActionStatus.pending);
  });

  test('batch actions restore with per-delivery ordering intact', () async {
    final store = MemoryOfflineQueueRepository();
    final queue = RiderOfflineActionQueue(repository: store, clock: () => now);
    await queue.initialize('rider-a');
    final first = await _add(queue, 'delivery-a', 'a-status');
    await _add(queue, 'delivery-a', 'a-proof', dependencyId: first.localId);
    await _add(queue, 'delivery-b', 'b-location');

    final restored = RiderOfflineActionQueue(
      repository: store,
      clock: () => now,
    );
    await restored.initialize('rider-a');

    expect(restored.actions, hasLength(3));
    expect(restored.actions.map((item) => item.sequence), [1, 2, 3]);
    expect(restored.actions[1].dependencyId, restored.actions.first.localId);
    expect(restored.actions.last.deliveryId, 'delivery-b');
  });
}

Future<OfflineDeliveryAction> _add(
  RiderOfflineActionQueue queue,
  String deliveryId,
  String key, {
  String? dependencyId,
}) => queue.add(
  riderId: 'rider-a',
  deliveryId: deliveryId,
  type: OfflineDeliveryActionType.deliveryStatusUpdate,
  payload: {'deliveryId': deliveryId},
  originalTimestamp: DateTime.utc(2032),
  idempotencyKey: key,
  dependencyId: dependencyId,
);

class _BatchRemote implements RiderOfflineActionRemote {
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
