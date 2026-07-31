part of 'rider_delivery_controller.dart';

extension RiderDeliveryControllerProblems on RiderDeliveryController {
  bool get isBackendReachable => _isBackendReachable;

  RiderDeliveryProblemReport? problemReportFor(String deliveryId) {
    final saved = _deliveryProblemReports[deliveryId];
    if (saved != null) return saved;
    for (final action in _offlineQueue.actions.reversed) {
      if (action.deliveryId == deliveryId &&
          action.type == OfflineDeliveryActionType.problemReport &&
          action.payload['reportScope'] == 'deliveryProblem') {
        return RiderDeliveryProblemReport(
          id: action.idempotencyKey,
          deliveryId: action.deliveryId,
          riderId: action.riderId,
          kind: RiderDeliveryProblemKind.values.byName(
            action.payload['kind'] as String,
          ),
          location: DeliveryStatusLocation(
            latitude: (action.payload['latitude'] as num).toDouble(),
            longitude: (action.payload['longitude'] as num).toDouble(),
            accuracyMeters: (action.payload['accuracyMeters'] as num)
                .toDouble(),
            timestamp: action.originalTimestamp,
          ),
          createdAt: action.originalTimestamp,
          notes: action.payload['notes'] as String,
          photoReferences: List<String>.from(
            action.payload['photoReferences'] as List? ?? const [],
          ),
        );
      }
    }
    return null;
  }

  Future<DeliveryActionResult> reportDeliveryProblem({
    required String deliveryId,
    required String riderId,
    required RiderDeliveryProblemKind kind,
    required String notes,
    List<String> photoReferences = const [],
  }) async {
    final request = _request(deliveryId);
    final location = _currentRiderLocation;
    if (request == null || location == null || notes.trim().isEmpty) {
      return const DeliveryActionResult.failure(
        failure: DeliveryActionFailure.unavailable,
        message: 'Problem details and a current location are required.',
      );
    }
    if (photoReferences.any(
      (value) =>
          !value.startsWith('protected://') &&
          !value.startsWith('local-secure://'),
    )) {
      return const DeliveryActionResult.failure(
        failure: DeliveryActionFailure.unavailable,
        message: 'Problem photos must be stored securely.',
      );
    }
    final timestamp = DateTime.now();
    final report = RiderDeliveryProblemReport(
      id: _newAcceptanceKey(),
      deliveryId: deliveryId,
      riderId: riderId,
      kind: kind,
      location: location,
      createdAt: timestamp,
      notes: notes.trim(),
      photoReferences: List.unmodifiable(photoReferences),
    );
    _deliveryProblemReports[deliveryId] = report;
    _notify();
    if (!_isBackendReachable) {
      await _queueDeliveryProblem(report);
      return DeliveryActionResult.success(request);
    }
    try {
      final saved = await _repository.reportDeliveryProblem(report);
      _deliveryProblemReports[deliveryId] = saved;
      _notify();
      return DeliveryActionResult.success(request);
    } on DeliveryDomainException catch (error) {
      return _failure(error);
    }
  }

  Future<bool> updateDeliveryProblemStatus({
    required String riderId,
    required String reportId,
    required RiderDeliveryProblemStatus status,
  }) async {
    final updated = await _repository.updateDeliveryProblemStatus(
      riderId: riderId,
      reportId: reportId,
      status: status,
    );
    if (updated == null) return false;
    _deliveryProblemReports[updated.deliveryId] = updated;
    _notify();
    return true;
  }

  Future<void> _queueDeliveryProblem(RiderDeliveryProblemReport report) =>
      _queueProblemReport(
        riderId: report.riderId,
        deliveryId: report.deliveryId,
        idempotencyKey: report.id,
        reportedAt: report.createdAt,
        payload: {
          'reportScope': 'deliveryProblem',
          'kind': report.kind.name,
          'notes': report.notes,
          'latitude': report.location.latitude,
          'longitude': report.location.longitude,
          'accuracyMeters': report.location.accuracyMeters,
          'photoReferences': report.photoReferences,
        },
      );
}
