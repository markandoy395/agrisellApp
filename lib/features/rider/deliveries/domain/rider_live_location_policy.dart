import 'delivery_request.dart';
import 'delivery_status.dart';

/// Live tracking is deliberately limited to operational navigation stages.
bool isLiveLocationSharingStage(DeliveryStatus status) => switch (status) {
  DeliveryStatus.goingToPickup ||
  DeliveryStatus.arrivedAtPickup ||
  DeliveryStatus.waitingForProduct ||
  DeliveryStatus.pickupConfirmationRequired ||
  DeliveryStatus.productPickedUp ||
  DeliveryStatus.goingToBuyer ||
  DeliveryStatus.arrivedAtDelivery ||
  DeliveryStatus.waitingForBuyer ||
  DeliveryStatus.deliveryConfirmationRequired => true,
  _ => false,
};

class RiderLiveLocationAccess {
  const RiderLiveLocationAccess._(this.allowed, this.reason);

  final bool allowed;
  final String reason;

  factory RiderLiveLocationAccess.authorize({
    required DeliveryRequest request,
    required String riderId,
    required DeliveryStatus status,
  }) {
    if (!request.isAssignedTo(riderId)) {
      return const RiderLiveLocationAccess._(
        false,
        'Only the assigned rider may share live location.',
      );
    }
    if (!isLiveLocationSharingStage(status)) {
      return const RiderLiveLocationAccess._(
        false,
        'Live location is unavailable at this delivery stage.',
      );
    }
    return const RiderLiveLocationAccess._(
      true,
      'Live location sharing is active.',
    );
  }
}

class RiderLiveLocationSharingController {
  String? _deliveryId;
  bool _sharing = false;

  bool get isSharing => _sharing;
  String? get deliveryId => _deliveryId;

  RiderLiveLocationAccess update({
    required DeliveryRequest request,
    required String riderId,
    required DeliveryStatus status,
  }) {
    final access = RiderLiveLocationAccess.authorize(
      request: request,
      riderId: riderId,
      status: status,
    );
    _sharing = access.allowed;
    _deliveryId = access.allowed ? request.id : null;
    return access;
  }

  void stop() {
    _sharing = false;
    _deliveryId = null;
  }
}
