part of 'rider_delivery_controller.dart';

extension RiderDeliveryControllerWaiting on RiderDeliveryController {
  List<DeliveryCompletionRecord> get completionHistory =>
      List.unmodifiable(_completionHistory);

  bool isCompletingDelivery(String deliveryId) =>
      _completionOperations.containsKey(deliveryId);

  DateTime? get pickupWaitingStartedAt => _waitingStartedAt(
    statuses: const {
      DeliveryStatus.arrivedAtPickup,
      DeliveryStatus.waitingForProduct,
    },
    repositoryValue: (repository, id) => repository.pickupWaitingStartedAt(id),
  );

  DateTime? get deliveryWaitingStartedAt => _waitingStartedAt(
    statuses: const {
      DeliveryStatus.arrivedAtDelivery,
      DeliveryStatus.waitingForBuyer,
    },
    repositoryValue: (repository, id) =>
        repository.deliveryWaitingStartedAt(id),
  );

  DateTime? _waitingStartedAt({
    required Set<DeliveryStatus> statuses,
    required DateTime? Function(InMemoryRiderDeliveryRepository, String)
    repositoryValue,
  }) {
    for (final event in statusEvents) {
      if (statuses.contains(event.newStatus)) return event.timestamp;
    }
    final activeId = _requestForActive()?.id;
    final repository = _repository;
    if (activeId == null || repository is! InMemoryRiderDeliveryRepository) {
      return null;
    }
    return repositoryValue(repository, activeId);
  }
}
