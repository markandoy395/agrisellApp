import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../domain/offline_delivery_action.dart';
import '../domain/rider_offline_sync.dart';
import 'rider_offline_action_queue.dart';

part 'rider_offline_sync_engine_apply.dart';

abstract interface class RiderOfflineActionRemote {
  Future<OfflineActionSyncResult> synchronize(OfflineDeliveryAction action);
}

class RiderOfflineSyncEngine extends ChangeNotifier {
  RiderOfflineSyncEngine({
    required RiderOfflineActionQueue queue,
    required RiderOfflineActionRemote remote,
    RiderOfflineConflictResolver conflictResolver =
        const RiderOfflineConflictResolver(),
    DateTime Function()? clock,
  }) : this._(queue, remote, conflictResolver, clock ?? DateTime.now);

  RiderOfflineSyncEngine._(
    this._queue,
    this._remote,
    this._conflictResolver,
    this._clock,
  ) {
    _queue.addListener(_queueChanged);
  }

  final RiderOfflineActionQueue _queue;
  final RiderOfflineActionRemote _remote;
  final RiderOfflineConflictResolver _conflictResolver;
  final DateTime Function() _clock;
  RiderOfflineSyncState _state = RiderOfflineSyncState.live;
  Future<void>? _operation;
  bool _backendReachable = true;
  DateTime? _lastSynchronizedAt;
  Timer? _retryTimer;

  RiderOfflineSyncState get state => _state;
  DateTime? get lastSynchronizedAt => _lastSynchronizedAt;
  bool get isSynchronizing => _operation != null;

  void setBackendReachable(bool reachable) {
    _backendReachable = reachable;
    if (!reachable) {
      _retryTimer?.cancel();
      _setState(
        _queue.pendingCount == 0
            ? RiderOfflineSyncState.offline
            : RiderOfflineSyncState.waiting,
      );
      return;
    }
    unawaited(synchronize());
  }

  Future<void> synchronize() {
    final running = _operation;
    if (running != null) return running;
    late final Future<void> operation;
    operation = _synchronizeOnce().whenComplete(() {
      if (identical(_operation, operation)) _operation = null;
    });
    _operation = operation;
    return operation;
  }

  Future<bool> retry(String localId) async {
    if (!await _queue.retry(localId)) return false;
    if (_backendReachable) await synchronize();
    return true;
  }

  Future<void> _synchronizeOnce() async {
    if (!_backendReachable) {
      _queueChanged();
      return;
    }
    final candidates = [..._queue.actions]
      ..sort((a, b) => a.sequence.compareTo(b.sequence));
    if (!candidates.any(_readyToSend)) {
      _finishState();
      return;
    }
    _setState(RiderOfflineSyncState.synchronizing);
    for (final action in candidates) {
      if (!_readyToSend(action)) continue;
      final dependency = action.dependencyId;
      if (dependency != null &&
          _queue.actions.any((item) => item.localId == dependency)) {
        // A blocked chain must not prevent an independent delivery from
        // synchronizing. Per-delivery dependencies still preserve order.
        continue;
      }
      final attemptedAt = _clock();
      await _queue.update(
        action.copyWith(
          status: OfflineDeliveryActionStatus.synchronizing,
          lastAttemptAt: attemptedAt,
        ),
      );
      OfflineActionSyncResult result;
      try {
        result = await _remote.synchronize(action);
      } on TimeoutException {
        result = const OfflineActionSyncResult.retryable(
          'The backend timed out.',
        );
      } on Exception {
        result = const OfflineActionSyncResult.retryable(
          'The backend could not be reached.',
        );
      }
      await _apply(action, result, attemptedAt);
      if (result.disposition == OfflineSyncDisposition.retryableFailure) break;
    }
    _lastSynchronizedAt = _clock();
    _finishState();
  }

  bool _readyToSend(OfflineDeliveryAction action) {
    if (action.status != OfflineDeliveryActionStatus.pending) return false;
    final next = action.nextAttemptAt;
    return next == null || !next.isAfter(_clock());
  }

  void _queueChanged() {
    if (_state != RiderOfflineSyncState.synchronizing) _finishState();
  }

  void _finishState() {
    if (!_backendReachable) {
      _setState(
        _queue.pendingCount == 0
            ? RiderOfflineSyncState.offline
            : RiderOfflineSyncState.waiting,
      );
    } else if (_queue.failedCount > 0) {
      _setState(RiderOfflineSyncState.failed);
    } else if (_queue.requiresAttentionCount > 0) {
      _setState(RiderOfflineSyncState.requiresAttention);
    } else if (_queue.pendingCount > 0) {
      _setState(RiderOfflineSyncState.waiting);
    } else {
      _setState(
        _lastSynchronizedAt == null
            ? RiderOfflineSyncState.live
            : RiderOfflineSyncState.synchronized,
      );
    }
    _scheduleRetry();
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    if (!_backendReachable) {
      return;
    }
    DateTime? next;
    for (final action in _queue.actions) {
      if (action.status != OfflineDeliveryActionStatus.pending ||
          action.nextAttemptAt == null) {
        continue;
      }
      if (next == null || action.nextAttemptAt!.isBefore(next)) {
        next = action.nextAttemptAt;
      }
    }
    if (next == null) {
      return;
    }
    final delay = next.difference(_clock());
    _retryTimer = Timer(delay.isNegative ? Duration.zero : delay, () {
      unawaited(synchronize());
    });
  }

  void _setState(RiderOfflineSyncState value) {
    if (_state == value) return;
    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _queue.removeListener(_queueChanged);
    super.dispose();
  }
}
