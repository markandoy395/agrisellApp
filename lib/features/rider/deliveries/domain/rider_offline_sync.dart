import 'offline_delivery_action.dart';

enum RiderOfflineSyncState {
  live,
  offline,
  waiting,
  synchronizing,
  synchronized,
  failed,
  requiresAttention,
}

extension RiderOfflineSyncStateDetails on RiderOfflineSyncState {
  String get label => switch (this) {
    RiderOfflineSyncState.live => 'Live',
    RiderOfflineSyncState.offline => 'Offline',
    RiderOfflineSyncState.waiting => 'Waiting to synchronize',
    RiderOfflineSyncState.synchronizing => 'Synchronizing',
    RiderOfflineSyncState.synchronized => 'Synchronized',
    RiderOfflineSyncState.failed => 'Failed',
    RiderOfflineSyncState.requiresAttention => 'Requires attention',
  };
}

enum OfflineActionConflict {
  deliveryCancelled,
  deliveryReassigned,
  serverStatusNewer,
  proofAlreadyUploaded,
  duplicateStatusUpdate,
  deliveryAlreadyCompleted,
  actionNoLongerValid,
  deliveryRequirementsChanged,
}

enum OfflineSyncDisposition {
  acknowledged,
  deferred,
  retryableFailure,
  permanentFailure,
  conflict,
}

class OfflineActionSyncResult {
  const OfflineActionSyncResult._(
    this.disposition, {
    this.message,
    this.conflict,
  });

  const OfflineActionSyncResult.acknowledged()
    : this._(OfflineSyncDisposition.acknowledged);

  const OfflineActionSyncResult.deferred()
    : this._(OfflineSyncDisposition.deferred);

  const OfflineActionSyncResult.retryable(String message)
    : this._(OfflineSyncDisposition.retryableFailure, message: message);

  const OfflineActionSyncResult.permanent(String message)
    : this._(OfflineSyncDisposition.permanentFailure, message: message);

  const OfflineActionSyncResult.conflict(
    OfflineActionConflict conflict,
    String message,
  ) : this._(
        OfflineSyncDisposition.conflict,
        conflict: conflict,
        message: message,
      );

  final OfflineSyncDisposition disposition;
  final String? message;
  final OfflineActionConflict? conflict;
}

enum OfflineConflictResolution { acknowledge, cancel, requiresAttention }

class RiderOfflineConflictResolver {
  const RiderOfflineConflictResolver();

  OfflineConflictResolution resolve(
    OfflineDeliveryAction action,
    OfflineActionConflict conflict,
  ) => switch (conflict) {
    OfflineActionConflict.proofAlreadyUploaded ||
    OfflineActionConflict.duplicateStatusUpdate =>
      OfflineConflictResolution.acknowledge,
    OfflineActionConflict.deliveryAlreadyCompleted =>
      OfflineConflictResolution.cancel,
    OfflineActionConflict.deliveryCancelled ||
    OfflineActionConflict.deliveryReassigned ||
    OfflineActionConflict.serverStatusNewer ||
    OfflineActionConflict.actionNoLongerValid ||
    OfflineActionConflict.deliveryRequirementsChanged =>
      OfflineConflictResolution.requiresAttention,
  };
}
