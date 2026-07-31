part of 'rider_delivery_controller.dart';

extension RiderDeliveryControllerState on RiderDeliveryController {
  RiderRequestLoadState get loadState => _loadState;
  RiderDeliveryStatus get status => _status;
  List<DeliveryRequest> get requests => List.unmodifiable(_requests);
  String? get errorMessage => _errorMessage;
  int get pendingOfflineActionCount => _pendingOfflineActionCount;
  DateTime? get lastSynchronizationTime => _lastSynchronizationTime;
  RiderOfflineSyncState get offlineSyncState => _syncEngine.state;
  List<OfflineDeliveryAction> get offlineActions => _offlineQueue.actions;
  RiderOfflineActionQueue get offlineQueue => _offlineQueue;
  bool get hasActiveDelivery =>
      hasAssignedActiveDelivery(_requests, _riderId ?? '');
  bool get usesTemporaryData => _repository is InMemoryRiderDeliveryRepository;
  ActiveDeliveryRecord? get activeDelivery => _activeDeliveries.selectedRecord;
  List<ActiveDeliveryRecord> get activeDeliveryRecords =>
      _activeDeliveries.records;
  DeliveryStatus? get activeDeliveryStatus => _activeDeliveries.selectedStatus;
  List<DeliveryStatusEvent> get statusEvents =>
      _activeDeliveries.selectedEvents;
  DeliveryStatusLocation? get currentRiderLocation => _currentRiderLocation;

  List<DeliveryStatusEvent> statusEventsFor(String deliveryId) =>
      _activeDeliveries.eventsFor(deliveryId);

  DeliveryStatus statusFor(DeliveryRequest request) =>
      _activeDeliveries.statusFor(request.id) ?? request.stage.canonicalStatus;

  bool isUpdatingStatus(String deliveryId) =>
      _statusOperations.containsKey(deliveryId);

  bool isCompletingPickup(String deliveryId) =>
      _pickupOperations.containsKey(deliveryId);

  bool isAcceptingRequest(String requestId) =>
      _acceptanceOperations.containsKey(requestId);

  bool canAcceptRequest(String requestId) =>
      canReceiveAdditionalDelivery &&
      !isAcceptingRequest(requestId) &&
      _requests.any(
        (request) =>
            request.id == requestId &&
            request.stage == DeliveryStage.readyForPickup,
      );

  void updateCurrentRiderLocation(RiderLocation? location) {
    final next = location == null
        ? null
        : DeliveryStatusLocation(
            latitude: location.latitude,
            longitude: location.longitude,
            accuracyMeters: location.accuracyMeters,
            altitudeMeters: location.altitudeMeters,
            speedMetersPerSecond: location.speedMetersPerSecond,
            headingDegrees: location.headingDegrees,
            timestamp: location.timestamp,
            isMocked: location.isMocked,
            isApproximate: location.isApproximate,
          );
    if (_sameLocationEvidence(_currentRiderLocation, next)) return;
    _currentRiderLocation = next;
    _notify();
  }

  DeliveryRequest? _requestForActive() {
    for (final request in _requests) {
      if (request.isAssignedTo(_riderId ?? '') && !request.stage.isTerminal) {
        return request;
      }
    }
    return null;
  }
}
