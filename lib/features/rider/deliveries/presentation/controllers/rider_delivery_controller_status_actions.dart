part of 'rider_delivery_controller.dart';

extension RiderDeliveryControllerStatusActions on RiderDeliveryController {
  Future<DeliveryActionResult> updateStatus({
    required String deliveryId,
    required String riderId,
    required DeliveryStatus newStatus,
    DeliveryStatusLocation? location,
    bool manualArrivalOverride = false,
    String? manualOverrideReason,
    String? manualOverrideNotes,
    String? note,
    String? reasonCode,
    String? proofReference,
  }) {
    final running = _statusOperations[deliveryId];
    if (running != null) return running;
    final request = _request(deliveryId);
    final previous = request == null ? null : statusFor(request);
    if (request == null || previous == null) return _missingDelivery();
    final command = DeliveryStatusUpdateCommand(
      deliveryId: deliveryId,
      riderId: riderId,
      previousStatus: previous,
      newStatus: newStatus,
      idempotencyKey: _newAcceptanceKey(),
      location: location,
      manualArrivalOverride: manualArrivalOverride,
      manualOverrideReason: manualOverrideReason,
      manualOverrideNotes: manualOverrideNotes,
      note: note,
      reasonCode: reasonCode,
      proofReference: proofReference,
    );
    try {
      const DeliveryTransitionValidator().validate(previous, newStatus);
      if (command.requiresArrivalLocation && !command.hasValidArrivalEvidence) {
        throw const DeliveryTransitionException(
          'A valid location or approved manual override is required on arrival.',
        );
      }
    } on DeliveryDomainException catch (error) {
      return Future.value(_failure(error));
    }
    late final Future<DeliveryActionResult> operation;
    operation = _updateStatusOnce(command).whenComplete(() {
      if (identical(_statusOperations[deliveryId], operation)) {
        _statusOperations.remove(deliveryId);
        _notify();
      }
    });
    _statusOperations[deliveryId] = operation;
    _notify();
    return operation;
  }

  Future<DeliveryActionResult> _updateStatusOnce(
    DeliveryStatusUpdateCommand command,
  ) async {
    if (!_isBackendReachable) return _queueStatusUpdate(command);
    if (!_status.canManageActiveDelivery) {
      return const DeliveryActionResult.failure(
        failure: DeliveryActionFailure.notEligible,
        message: 'Verification and online availability are required.',
      );
    }
    try {
      final snapshot = await _repository
          .updateDeliveryStatus(command)
          .timeout(_acceptanceTimeout);
      _activeDeliveries.update(snapshot);
      await _replace(snapshot.request, riderId: command.riderId);
      return DeliveryActionResult.success(snapshot.request);
    } on TimeoutException {
      return _queueStatusUpdate(command);
    } on DeliveryDomainException catch (error) {
      if (error.code == DeliveryErrorCode.networkUnavailable) {
        return _queueStatusUpdate(command);
      }
      return _failure(error);
    } catch (_) {
      return const DeliveryActionResult.failure(
        failure: DeliveryActionFailure.unknown,
        message: 'The delivery update could not be completed.',
      );
    }
  }

  DeliveryRequest? _request(String deliveryId) {
    for (final item in _requests) {
      if (item.id == deliveryId) return item;
    }
    return null;
  }

  Future<DeliveryActionResult> _missingDelivery() => Future.value(
    const DeliveryActionResult.failure(
      failure: DeliveryActionFailure.unavailable,
      message: 'This delivery is no longer available.',
    ),
  );

  DeliveryActionResult _failure(DeliveryDomainException error) =>
      DeliveryActionResult.failure(
        failure: _legacyFailureFor(error.code),
        message: error.message,
      );
}
