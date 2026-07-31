part of 'rider_delivery_repository.dart';

extension _InMemoryRiderDeliveryStatus on InMemoryRiderDeliveryRepository {
  Future<DeliveryStatusSnapshot> _updateDeliveryStatus(
    DeliveryStatusUpdateCommand command,
  ) async {
    final key = '${command.riderId}|${command.idempotencyKey}';
    final replay = _statusIdempotency[key];
    if (replay != null) return replay;
    final request = _requestFor(command.deliveryId);
    if (!request.isAssignedTo(command.riderId)) {
      throw const DeliveryTransitionException(
        'This delivery is not assigned to this rider.',
        code: DeliveryErrorCode.unauthorizedOperation,
      );
    }
    final current = _snapshotFor(request);
    if (command.newStatus == DeliveryStatus.productDelivered ||
        command.newStatus == DeliveryStatus.deliveryCompleted) {
      throw const DeliveryTransitionException(
        'Use the configured delivery confirmation workflow to complete this delivery.',
        code: DeliveryErrorCode.invalidProof,
      );
    }
    if (current.currentStatus != command.previousStatus) {
      throw const DeliveryTransitionException(
        'This delivery changed on the server. Refresh before trying again.',
        code: DeliveryErrorCode.synchronizationConflict,
      );
    }
    if (command.requiresArrivalLocation && !command.hasValidArrivalEvidence) {
      throw const DeliveryTransitionException(
        'A valid location or approved manual override is required on arrival.',
      );
    }
    if (command.newStatus == DeliveryStatus.arrivedAtPickup ||
        command.newStatus == DeliveryStatus.arrivedAtDelivery) {
      _validateArrival(request, command);
    }
    const DeliveryTransitionValidator().validate(
      command.previousStatus,
      command.newStatus,
    );
    final event = _eventFor(command, current.events.length + 1);
    if (command.newStatus == DeliveryStatus.arrivedAtPickup) {
      _pickupWaitingStartedAt[request.id] = event.timestamp;
    }
    if (command.newStatus == DeliveryStatus.waitingForProduct &&
        !_pickupWaitingStartedAt.containsKey(request.id)) {
      _pickupWaitingStartedAt[request.id] = event.timestamp;
    }
    if (command.newStatus == DeliveryStatus.arrivedAtDelivery) {
      _deliveryWaitingStartedAt[request.id] = event.timestamp;
      _buyerArrivalNotifications.add(request.id);
    }
    if (command.newStatus == DeliveryStatus.waitingForBuyer &&
        !_deliveryWaitingStartedAt.containsKey(request.id)) {
      _deliveryWaitingStartedAt[request.id] = event.timestamp;
    }
    final updatedRequest = request.copyWith(
      stage: legacyStageForDeliveryStatus(command.newStatus),
      closedAt: command.newStatus == DeliveryStatus.deliveryCompleted
          ? event.timestamp
          : request.closedAt,
    );
    final updated = DeliveryStatusSnapshot(
      request: updatedRequest,
      currentStatus: command.newStatus,
      events: List.unmodifiable([...current.events, event]),
    );
    _requests[request.id] = updatedRequest;
    _statusSnapshots[request.id] = updated;
    _statusIdempotency[key] = updated;
    if (command.newStatus == DeliveryStatus.deliveryCompleted) {
      _removeActiveAssignment(command.riderId, command.deliveryId);
    }
    _changes.add(null);
    return updated;
  }

  Future<DeliveryStatusSnapshot?> _fetchActiveDeliveryStatus(
    String riderId,
  ) async {
    final active = _activeDeliveries[riderId]?.values.firstOrNull;
    final request = active == null
        ? _requests.values
              .where(
                (item) => item.isAssignedTo(riderId) && !item.stage.isTerminal,
              )
              .firstOrNull
        : _requests[active.requestId];
    return request == null ? null : _snapshotFor(request);
  }

  Future<List<DeliveryStatusSnapshot>> _fetchActiveDeliveryStatuses(
    String riderId,
  ) async => _requests.values
      .where((item) => item.isAssignedTo(riderId) && !item.stage.isTerminal)
      .map(_snapshotFor)
      .toList(growable: false);

  DeliveryStatusSnapshot _snapshotFor(DeliveryRequest request) =>
      _statusSnapshots[request.id] ??
      DeliveryStatusSnapshot(
        request: request,
        currentStatus: request.stage.canonicalStatus,
        events: const [],
      );

  void _validateArrival(
    DeliveryRequest request,
    DeliveryStatusUpdateCommand command,
  ) {
    final configuration =
        _pickupConfigurations[request.id] ??
        const PickupConfiguration(requiredMethods: {});
    final location = command.location!;
    if (command.manualArrivalOverride) {
      if ((command.newStatus == DeliveryStatus.arrivedAtPickup &&
              command.manualOverrideReason == 'delivery_pin_incorrect') ||
          (command.newStatus == DeliveryStatus.arrivedAtDelivery &&
              command.manualOverrideReason == 'pickup_pin_incorrect')) {
        throw const DeliveryTransitionException(
          'The manual arrival reason does not match this destination.',
        );
      }
      final target = command.newStatus == DeliveryStatus.arrivedAtDelivery
          ? request.deliveryLocation
          : request.pickupLocation;
      final result = validateRiderArrival(
        location: location,
        target: target,
        radiusMeters: configuration.arrivalRadiusMeters,
        maxAccuracyMeters: configuration.maxArrivalAccuracyMeters,
        manualOverrideReason: command.manualOverrideReason,
        manualOverrideNotes: command.manualOverrideNotes,
        now: _clock(),
      );
      if (!result.isValid) {
        throw DeliveryTransitionException(
          result.message ?? 'Manual arrival validation failed.',
        );
      }
      return;
    }
    final target = command.newStatus == DeliveryStatus.arrivedAtDelivery
        ? request.deliveryLocation
        : request.pickupLocation;
    if (!target.hasCoordinates) {
      if (_pickupConfigurations.containsKey(request.id) ||
          command.newStatus == DeliveryStatus.arrivedAtDelivery) {
        throw const DeliveryTransitionException(
          'Arrival coordinates cannot be verified; use an approved manual override.',
        );
      }
      // Legacy request fixtures can omit a target coordinate. Production
      // configurations must provide one or use the manual-override branch.
      return;
    }
    final result = validateRiderArrival(
      location: location,
      target: target,
      radiusMeters: configuration.arrivalRadiusMeters,
      maxAccuracyMeters: configuration.maxArrivalAccuracyMeters,
      manualOverrideReason: command.manualArrivalOverride
          ? command.manualOverrideReason
          : null,
      manualOverrideNotes: command.manualOverrideNotes,
      now: _clock(),
    );
    if (!result.isValid) {
      throw DeliveryTransitionException(
        result.message ?? 'Arrival validation failed.',
      );
    }
  }
}
