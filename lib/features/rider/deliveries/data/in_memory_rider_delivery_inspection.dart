part of 'rider_delivery_repository.dart';

extension InMemoryRiderDeliveryInspection on InMemoryRiderDeliveryRepository {
  /// Test/development seam standing in for server-owned Rider records.
  void setAuthoritativeRiderState(RiderAcceptanceState state) {
    _riderStates[state.riderId] = state;
  }

  RiderAcceptanceState? authoritativeRiderState(String riderId) =>
      _riderStates[riderId];

  ActiveDeliveryRecord? activeDeliveryFor(String riderId) =>
      _activeDeliveries[riderId]?.values.firstOrNull;

  List<ActiveDeliveryRecord> activeDeliveriesFor(String riderId) =>
      List.unmodifiable(_activeDeliveries[riderId]?.values ?? const []);

  PickupCompletionRecord? pickupRecordFor(String deliveryId) =>
      _pickupRecords[deliveryId];

  DateTime? pickupWaitingStartedAt(String deliveryId) =>
      _pickupWaitingStartedAt[deliveryId];

  DeliveryCompletionRecord? completionRecordFor(String deliveryId) =>
      _completionHistory[deliveryId];

  CashCollectionRecord? cashCollectionIssueFor(String deliveryId) =>
      _cashCollectionIssues[deliveryId];

  DateTime? deliveryWaitingStartedAt(String deliveryId) =>
      _deliveryWaitingStartedAt[deliveryId];

  bool buyerArrivalNotified(String deliveryId) =>
      _buyerArrivalNotifications.contains(deliveryId);

  RiderDeliveryProblemReport? deliveryProblemFor(String deliveryId) {
    for (final report in _deliveryProblems.values) {
      if (report.deliveryId == deliveryId) return report;
    }
    return null;
  }

  DeliveryRequest _replace(String id, DeliveryRequest request) {
    final previous = _requests[id];
    _requests[id] = request;
    if (previous != null &&
        !previous.stage.isTerminal &&
        request.stage.isTerminal) {
      _removeActiveAssignment(request.assignedRiderId, id);
    }
    _changes.add(null);
    return request;
  }

  DeliveryRequest _requestFor(String id) {
    final request = _requests[id];
    if (request == null) throw const DeliveryDomainException.notFound();
    return request;
  }
}
