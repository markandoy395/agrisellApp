part of 'rider_delivery_controller.dart';

extension RiderDeliveryControllerPickup on RiderDeliveryController {
  Future<PickupConfiguration> pickupConfiguration({
    required String deliveryId,
    required String riderId,
  }) => _repository.fetchPickupConfiguration(
    deliveryId: deliveryId,
    riderId: riderId,
  );

  Future<DeliveryActionResult> completePickup(PickupCompletionCommand command) {
    final validation = validatePickupCompletion(command);
    if (!validation.isValid) {
      return Future.value(
        DeliveryActionResult.failure(
          failure: DeliveryActionFailure.proofRequired,
          message: validation.message,
        ),
      );
    }
    final running = _pickupOperations[command.deliveryId];
    if (running != null) return running;
    late final Future<DeliveryActionResult> operation;
    operation = _completePickupOnce(command).whenComplete(() {
      if (identical(_pickupOperations[command.deliveryId], operation)) {
        _pickupOperations.remove(command.deliveryId);
        _notify();
      }
    });
    _pickupOperations[command.deliveryId] = operation;
    _notify();
    return operation;
  }

  Future<DeliveryActionResult> _completePickupOnce(
    PickupCompletionCommand command,
  ) async {
    if (!_isBackendReachable) return _queuePickupProof(command);
    if (!_status.canManageActiveDelivery) {
      return const DeliveryActionResult.failure(
        failure: DeliveryActionFailure.notEligible,
        message: 'Verification and online availability are required.',
      );
    }
    try {
      final result = await _repository
          .completePickup(command)
          .timeout(_acceptanceTimeout);
      _activeDeliveries.update(result.status);
      await _replace(result.status.request, riderId: command.riderId);
      return DeliveryActionResult.success(result.status.request);
    } on TimeoutException {
      return _queuePickupProof(command);
    } on DeliveryDomainException catch (error) {
      if (error.code == DeliveryErrorCode.networkUnavailable) {
        return _queuePickupProof(command);
      }
      return DeliveryActionResult.failure(
        failure: _legacyFailureFor(error.code),
        message: error.message,
      );
    } catch (_) {
      return const DeliveryActionResult.failure(
        failure: DeliveryActionFailure.unknown,
        message: 'Pickup confirmation could not be completed.',
      );
    }
  }

  Future<PickupProblemReport?> reportPickupProblem(
    PickupProblemReport report,
  ) async {
    if (!_isBackendReachable) {
      await _queueProblemReport(
        riderId: report.riderId,
        deliveryId: report.deliveryId,
        idempotencyKey: report.id,
        reportedAt: report.reportedAt,
        payload: {
          'kind': report.kind.name,
          'notes': report.notes,
          'photoReferences': report.photoReferences,
          'latitude': report.location.latitude,
          'longitude': report.location.longitude,
          'accuracyMeters': report.location.accuracyMeters,
        },
      );
      return report;
    }
    try {
      return await _repository.reportPickupProblem(report);
    } on DeliveryDomainException {
      return null;
    }
  }
}
