part of 'rider_offline_sync_engine.dart';

extension _RiderOfflineSyncApplication on RiderOfflineSyncEngine {
  Future<void> _apply(
    OfflineDeliveryAction action,
    OfflineActionSyncResult result,
    DateTime attemptedAt,
  ) async {
    switch (result.disposition) {
      case OfflineSyncDisposition.acknowledged:
        await _queue.acknowledge(action.localId);
      case OfflineSyncDisposition.deferred:
        break;
      case OfflineSyncDisposition.retryableFailure:
        final retries = action.retryCount + 1;
        final exhausted = retries >= action.maxRetries;
        await _queue.update(
          action.copyWith(
            status: exhausted
                ? OfflineDeliveryActionStatus.failed
                : OfflineDeliveryActionStatus.pending,
            retryCount: retries,
            lastError: result.message,
            lastAttemptAt: attemptedAt,
            nextAttemptAt: exhausted
                ? null
                : attemptedAt.add(retryDelay(retries)),
            clearNextAttempt: exhausted,
          ),
        );
      case OfflineSyncDisposition.permanentFailure:
        await _queue.update(
          action.copyWith(
            status: OfflineDeliveryActionStatus.requiresAttention,
            retryCount: action.retryCount + 1,
            lastError: result.message,
            lastAttemptAt: attemptedAt,
            clearNextAttempt: true,
          ),
        );
      case OfflineSyncDisposition.conflict:
        await _applyConflict(action, result, attemptedAt);
    }
  }

  Future<void> _applyConflict(
    OfflineDeliveryAction action,
    OfflineActionSyncResult result,
    DateTime attemptedAt,
  ) async {
    final resolution = _conflictResolver.resolve(action, result.conflict!);
    if (resolution == OfflineConflictResolution.acknowledge) {
      await _queue.acknowledge(action.localId);
      return;
    }
    await _queue.update(
      action.copyWith(
        status: resolution == OfflineConflictResolution.cancel
            ? OfflineDeliveryActionStatus.cancelled
            : OfflineDeliveryActionStatus.requiresAttention,
        lastError: result.message,
        lastAttemptAt: attemptedAt,
        clearNextAttempt: true,
      ),
    );
  }
}

Duration retryDelay(int retryCount) =>
    Duration(seconds: min(300, 5 * pow(2, max(0, retryCount - 1)).toInt()));
