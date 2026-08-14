part of 'rider_delivery_repository.dart';

extension _InMemoryRiderBatch on InMemoryRiderDeliveryRepository {
  void _validateBatchAcceptance(
    DeliveryRequest candidate,
    RiderAcceptanceState rider,
  ) {
    final active = _requests.values
        .where(
          (item) => item.isAssignedTo(rider.riderId) && !item.stage.isTerminal,
        )
        .toList(growable: false);
    if (active.isEmpty) return;
    final rejection = _batchAcceptanceRejection(
      candidate: candidate,
      rider: rider,
      active: active,
    );
    if (rejection == null) return;
    final failure = switch (rejection) {
      RiderBatchRejection.activeDeliveryLimit =>
        DeliveryAcceptanceFailure.activeDeliveryLimit,
      RiderBatchRejection.capacityUnknown ||
      RiderBatchRejection.capacityExceeded =>
        DeliveryAcceptanceFailure.capacityMismatch,
      _ => DeliveryAcceptanceFailure.batchIncompatible,
    };
    throw DeliveryAcceptanceException(failure);
  }

  RiderBatchRejection? _batchAcceptanceRejection({
    required DeliveryRequest candidate,
    required RiderAcceptanceState rider,
    Iterable<DeliveryRequest>? active,
  }) {
    final current =
        active ??
        _requests.values.where(
          (item) => item.isAssignedTo(rider.riderId) && !item.stage.isTerminal,
        );
    if (current.isEmpty) return null;
    final evaluation = const RiderBatchOptimizer().evaluate(
      activeDeliveries: current,
      candidate: candidate,
      context: RiderBatchContext(
        riderEligible: rider.isAllowedToDeliver,
        maximumActiveDeliveries: rider.maximumActiveDeliveries,
        capacityKg: rider.capacityKg,
        vehicleType: rider.vehicleType,
        currentLocation: rider.location,
        handlingCapabilityKeys: rider.handlingCapabilityKeys,
        now: _clock(),
      ),
    );
    return evaluation.rejection;
  }

  void _removeActiveAssignment(String? riderId, String deliveryId) {
    if (riderId == null) return;
    _activeByRequest.remove(deliveryId);
    final riderDeliveries = _activeDeliveries[riderId];
    riderDeliveries?.remove(deliveryId);
    if (riderDeliveries?.isEmpty ?? false) _activeDeliveries.remove(riderId);
    final state = _riderStates[riderId];
    if (state != null) _riderStates[riderId] = state.release();
  }
}
