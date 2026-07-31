part of 'rider_delivery_controller.dart';

extension RiderDeliveryControllerCompletion on RiderDeliveryController {
  Future<DeliveryCompletionConfiguration> fetchDeliveryConfiguration({
    required String deliveryId,
    required String riderId,
  }) => _repository.fetchDeliveryConfiguration(
    deliveryId: deliveryId,
    riderId: riderId,
  );

  Future<void> refreshCompletionHistory({required String riderId}) async {
    try {
      final records = await _repository.fetchCompletedDeliveries(riderId);
      _completionHistory = List.unmodifiable(records);
      _notify();
    } on Exception {
      // Existing history remains visible when refresh fails.
    }
  }

  Future<DeliveryActionResult> completeDelivery({
    required DeliveryCompletionCommand command,
  }) {
    final running = _completionOperations[command.deliveryId];
    if (running != null) return running;
    late final Future<DeliveryActionResult> operation;
    operation = _completeDeliveryOnce(command).whenComplete(() {
      if (identical(_completionOperations[command.deliveryId], operation)) {
        _completionOperations.remove(command.deliveryId);
        _notify();
      }
    });
    _completionOperations[command.deliveryId] = operation;
    _notify();
    return operation;
  }

  Future<DeliveryActionResult> _completeDeliveryOnce(
    DeliveryCompletionCommand command,
  ) async {
    if (!_isBackendReachable) return _queueDeliveryProof(command);
    if (!_status.canManageActiveDelivery) {
      return const DeliveryActionResult.failure(
        failure: DeliveryActionFailure.notEligible,
        message: 'Verification and online availability are required.',
      );
    }
    try {
      final result = await _repository
          .completeDelivery(command)
          .timeout(_acceptanceTimeout);
      final record = result.record;
      _activeDeliveries.remove(command.deliveryId);
      _completionHistory = List.unmodifiable([
        for (final item in _completionHistory)
          if (item.request.id != record.request.id) item,
        record,
      ]);
      await _replace(record.request, riderId: command.riderId);
      return DeliveryActionResult.success(record.request);
    } on TimeoutException {
      return _queueDeliveryProof(command);
    } on DeliveryDomainException catch (error) {
      if (error.code == DeliveryErrorCode.networkUnavailable) {
        return _queueDeliveryProof(command);
      }
      return _failure(error);
    } catch (_) {
      return const DeliveryActionResult.failure(
        failure: DeliveryActionFailure.unknown,
        message: 'Delivery confirmation could not be validated by the server.',
      );
    }
  }

  Future<DeliveryActionResult> reportDestinationProblem({
    required String deliveryId,
    required String riderId,
    required String notes,
  }) async {
    final request = _request(deliveryId);
    final location = _currentRiderLocation;
    if (request == null || location == null || notes.trim().isEmpty) {
      return const DeliveryActionResult.failure(
        failure: DeliveryActionFailure.unavailable,
        message: 'Current location and problem details are required.',
      );
    }
    final reportId = _newAcceptanceKey();
    if (!_isBackendReachable) {
      await _queueProblemReport(
        riderId: riderId,
        deliveryId: deliveryId,
        idempotencyKey: reportId,
        reportedAt: DateTime.now(),
        payload: {
          'kind': 'destinationNotFound',
          'notes': notes.trim(),
          'latitude': location.latitude,
          'longitude': location.longitude,
          'accuracyMeters': location.accuracyMeters,
        },
      );
      return DeliveryActionResult.success(request);
    }
    try {
      await _repository.reportDestinationProblem(
        DeliveryDestinationProblemReport(
          id: reportId,
          deliveryId: deliveryId,
          riderId: riderId,
          location: location,
          reportedAt: DateTime.now(),
          notes: notes.trim(),
        ),
      );
      return DeliveryActionResult.success(request);
    } on DeliveryDomainException catch (error) {
      return _failure(error);
    }
  }
}
