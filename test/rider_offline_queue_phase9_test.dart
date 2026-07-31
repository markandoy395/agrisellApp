import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_foundation_repositories.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_offline_action_queue.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_offline_sync_engine.dart';
import 'package:agresell_app/features/rider/deliveries/domain/offline_delivery_action.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_offline_sync.dart';

part 'rider_offline_queue_phase9_support.dart';

void main() {
  late _MemoryQueueRepository store;
  late RiderOfflineActionQueue queue;
  late _ScriptedRemote remote;
  late RiderOfflineSyncEngine engine;
  final now = DateTime.utc(2030, 1, 1, 10);

  setUp(() {
    store = _MemoryQueueRepository();
    queue = RiderOfflineActionQueue(repository: store, clock: () => now);
    remote = _ScriptedRemote();
    engine = RiderOfflineSyncEngine(
      queue: queue,
      remote: remote,
      clock: () => now,
    );
  });

  tearDown(() => engine.dispose());

  test('queues ordered idempotent actions with all durable fields', () async {
    await queue.initialize('rider-1');
    final first = await _add(queue, now, key: 'same');
    final duplicate = await _add(
      queue,
      now.add(const Duration(seconds: 1)),
      key: 'same',
    );
    final second = await _add(queue, now.add(const Duration(seconds: 2)));

    expect(duplicate.localId, first.localId);
    expect(queue.actions, hasLength(2));
    expect(queue.actions.map((action) => action.sequence), [1, 2]);
    expect(second.originalTimestamp, now.add(const Duration(seconds: 2)));
    expect(first.maxRetries, greaterThan(0));
    expect(
      first.toJson().keys,
      containsAll(<String>[
        'localId',
        'idempotencyKey',
        'originalTimestamp',
        'createdAt',
        'retryCount',
        'maxRetries',
        'sequence',
        'lastAttemptAt',
      ]),
    );
  });

  test('restores pending actions after queue recreation', () async {
    await queue.initialize('rider-1');
    await _add(queue, now, type: OfflineDeliveryActionType.deliveryProof);

    final restored = RiderOfflineActionQueue(
      repository: store,
      clock: () => now,
    );
    await restored.initialize('rider-1');

    expect(restored.pendingCount, 1);
    expect(
      restored.actions.single.type,
      OfflineDeliveryActionType.deliveryProof,
    );
  });

  test('syncs in sequence and removes only acknowledged actions', () async {
    await queue.initialize('rider-1');
    await _add(queue, now, key: 'one');
    await _add(queue, now.add(const Duration(seconds: 1)), key: 'two');

    await engine.synchronize();

    expect(remote.sent, ['one', 'two']);
    expect(queue.actions, isEmpty);
    expect(engine.state, RiderOfflineSyncState.synchronized);
  });

  test('offline state retains actions until reconnection', () async {
    await queue.initialize('rider-1');
    await _add(queue, now);
    engine.setBackendReachable(false);

    await engine.synchronize();

    expect(queue.pendingCount, 1);
    expect(engine.state, RiderOfflineSyncState.waiting);
    engine.setBackendReachable(true);
    await engine.synchronize();
    expect(queue.actions, isEmpty);
  });

  test('retry and permanent failures retain safe state', () async {
    await queue.initialize('rider-1');
    final retry = await _add(queue, now, key: 'retry', maxRetries: 1);
    remote.results[retry.idempotencyKey] =
        const OfflineActionSyncResult.retryable('Backend unavailable');

    await engine.synchronize();

    expect(queue.actions.single.status, OfflineDeliveryActionStatus.failed);
    expect(engine.state, RiderOfflineSyncState.failed);
    remote.results.remove(retry.idempotencyKey);
    expect(await engine.retry(retry.localId), isTrue);
    expect(queue.actions, isEmpty);

    final permanent = await _add(queue, now, key: 'permanent');
    remote.results[permanent.idempotencyKey] =
        const OfflineActionSyncResult.permanent('Invalid proof');
    await engine.synchronize();
    expect(
      queue.actions.single.status,
      OfflineDeliveryActionStatus.requiresAttention,
    );
  });

  test('conflicts never overwrite server state', () async {
    await queue.initialize('rider-1');
    final cancelled = await _add(queue, now, key: 'cancelled');
    remote.results[cancelled.idempotencyKey] = OfflineActionSyncResult.conflict(
      OfflineActionConflict.deliveryCancelled,
      'Delivery was cancelled.',
    );
    await engine.synchronize();
    expect(
      queue.actions.single.status,
      OfflineDeliveryActionStatus.requiresAttention,
    );

    final completed = await _add(queue, now, key: 'completed');
    remote.results[completed.idempotencyKey] = OfflineActionSyncResult.conflict(
      OfflineActionConflict.deliveryAlreadyCompleted,
      'Delivery is already complete.',
    );
    await engine.synchronize();
    expect(queue.actions.last.status, OfflineDeliveryActionStatus.cancelled);
  });

  test('safe cleanup retains proof and photo evidence', () async {
    await queue.initialize('rider-1');
    final proof = await _add(
      queue,
      now,
      type: OfflineDeliveryActionType.deliveryProof,
    );
    final photo = await _add(queue, now, type: OfflineDeliveryActionType.photo);
    final status = await _add(queue, now, key: 'status');
    await queue.update(
      proof.copyWith(status: OfflineDeliveryActionStatus.cancelled),
    );
    await queue.update(
      photo.copyWith(status: OfflineDeliveryActionStatus.cancelled),
    );
    await queue.update(
      status.copyWith(status: OfflineDeliveryActionStatus.cancelled),
    );

    await queue.safeCleanup();

    expect(queue.actions, hasLength(2));
    expect(
      queue.actions.map((action) => action.type),
      containsAll(<OfflineDeliveryActionType>[
        OfflineDeliveryActionType.deliveryProof,
        OfflineDeliveryActionType.photo,
      ]),
    );
  });
}
