import 'offline_delivery_command_codec.dart';
import 'rider_delivery_repository.dart';
import 'rider_offline_sync_engine.dart';
import '../domain/delivery_errors.dart';
import '../domain/delivery_completion.dart';
import '../domain/delivery_status_update.dart';
import '../domain/offline_delivery_action.dart';
import '../domain/pickup_confirmation.dart';
import '../domain/rider_offline_sync.dart';
import '../domain/rider_delivery_problem.dart';

class RiderDeliveryOfflineRemote implements RiderOfflineActionRemote {
  const RiderDeliveryOfflineRemote(this._repository);

  final RiderDeliveryRepository _repository;

  @override
  Future<OfflineActionSyncResult> synchronize(
    OfflineDeliveryAction action,
  ) async {
    try {
      switch (action.type) {
        case OfflineDeliveryActionType.deliveryStatusUpdate:
        case OfflineDeliveryActionType.updateStatus:
          await _repository.updateDeliveryStatus(decodeStatusCommand(action));
        case OfflineDeliveryActionType.pickupProof:
          await _repository.completePickup(decodePickupCommand(action));
        case OfflineDeliveryActionType.deliveryProof:
          await _repository.completeDelivery(decodeDeliveryCommand(action));
        case OfflineDeliveryActionType.problemReport:
        case OfflineDeliveryActionType.reportProblem:
          await _synchronizeProblemReport(action);
        case OfflineDeliveryActionType.photo:
        case OfflineDeliveryActionType.submitProof:
        case OfflineDeliveryActionType.riderNote:
        case OfflineDeliveryActionType.location:
        case OfflineDeliveryActionType.recordLocation:
        case OfflineDeliveryActionType.message:
        case OfflineDeliveryActionType.failedDeliveryReport:
        case OfflineDeliveryActionType.safetyReport:
          return const OfflineActionSyncResult.deferred();
      }
      return const OfflineActionSyncResult.acknowledged();
    } on DeliveryDomainException catch (error) {
      return _mapDomainError(error);
    } on FormatException {
      return const OfflineActionSyncResult.permanent(
        'The saved action is invalid and needs review.',
      );
    } on TypeError {
      return const OfflineActionSyncResult.permanent(
        'The saved action is invalid and needs review.',
      );
    }
  }

  OfflineActionSyncResult _mapDomainError(DeliveryDomainException error) {
    return switch (error.code) {
      DeliveryErrorCode.networkUnavailable => OfflineActionSyncResult.retryable(
        error.message,
      ),
      DeliveryErrorCode.unauthorizedOperation =>
        OfflineActionSyncResult.conflict(
          OfflineActionConflict.deliveryReassigned,
          error.message,
        ),
      DeliveryErrorCode.deliveryNotFound ||
      DeliveryErrorCode.deliveryNoLongerAvailable =>
        OfflineActionSyncResult.conflict(
          OfflineActionConflict.actionNoLongerValid,
          error.message,
        ),
      DeliveryErrorCode.synchronizationConflict =>
        OfflineActionSyncResult.conflict(
          OfflineActionConflict.serverStatusNewer,
          error.message,
        ),
      DeliveryErrorCode.invalidStatusTransition ||
      DeliveryErrorCode.riderUnavailable ||
      DeliveryErrorCode.invalidProof ||
      DeliveryErrorCode.invalidPayment => OfflineActionSyncResult.permanent(
        error.message,
      ),
    };
  }

  Future<void> _synchronizeProblemReport(OfflineDeliveryAction action) async {
    final location = DeliveryStatusLocation(
      latitude: (action.payload['latitude'] as num).toDouble(),
      longitude: (action.payload['longitude'] as num).toDouble(),
      accuracyMeters: (action.payload['accuracyMeters'] as num).toDouble(),
      timestamp: action.originalTimestamp,
    );
    if (action.payload['reportScope'] == 'deliveryProblem') {
      await _repository.reportDeliveryProblem(
        RiderDeliveryProblemReport(
          id: action.idempotencyKey,
          deliveryId: action.deliveryId,
          riderId: action.riderId,
          kind: RiderDeliveryProblemKind.values.byName(
            action.payload['kind'] as String,
          ),
          location: location,
          createdAt: action.originalTimestamp,
          notes: action.payload['notes'] as String,
          photoReferences: List<String>.from(
            action.payload['photoReferences'] as List? ?? const [],
          ),
        ),
      );
      return;
    }
    if (action.payload['kind'] == 'destinationNotFound') {
      await _repository.reportDestinationProblem(
        DeliveryDestinationProblemReport(
          id: action.idempotencyKey,
          deliveryId: action.deliveryId,
          riderId: action.riderId,
          location: location,
          reportedAt: action.originalTimestamp,
          notes: action.payload['notes'] as String,
        ),
      );
      return;
    }
    await _repository.reportPickupProblem(
      PickupProblemReport(
        id: action.idempotencyKey,
        deliveryId: action.deliveryId,
        riderId: action.riderId,
        kind: PickupProblemKind.values.byName(action.payload['kind'] as String),
        reportedAt: action.originalTimestamp,
        location: location,
        notes: action.payload['notes'] as String,
        photoReferences: List<String>.from(
          action.payload['photoReferences'] as List? ?? const [],
        ),
      ),
    );
  }
}
