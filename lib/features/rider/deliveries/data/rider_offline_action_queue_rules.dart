part of 'rider_offline_action_queue.dart';

bool _isPending(OfflineDeliveryAction action) =>
    action.status == OfflineDeliveryActionStatus.pending ||
    action.status == OfflineDeliveryActionStatus.synchronizing ||
    action.status == OfflineDeliveryActionStatus.processing;

bool _isLocation(OfflineDeliveryAction action) =>
    action.type == OfflineDeliveryActionType.location ||
    action.type == OfflineDeliveryActionType.recordLocation;

List<OfflineDeliveryAction> _ordered(List<OfflineDeliveryAction> actions) =>
    actions..sort((a, b) {
      final sequence = a.sequence.compareTo(b.sequence);
      return sequence != 0
          ? sequence
          : a.originalTimestamp.compareTo(b.originalTimestamp);
    });

int _retryLimit(OfflineDeliveryActionType type) => _isLocationType(type)
    ? 12
    : type == OfflineDeliveryActionType.pickupProof ||
          type == OfflineDeliveryActionType.deliveryProof ||
          type == OfflineDeliveryActionType.photo ||
          type == OfflineDeliveryActionType.submitProof
    ? 8
    : 6;

bool _isLocationType(OfflineDeliveryActionType type) =>
    type == OfflineDeliveryActionType.location ||
    type == OfflineDeliveryActionType.recordLocation;
