part of 'rider_delivery_repository.dart';

extension _InMemoryRiderPickupConfirmation on InMemoryRiderDeliveryRepository {
  Future<PickupConfiguration> _fetchPickupConfiguration({
    required String deliveryId,
    required String riderId,
  }) async {
    final request = _requestFor(deliveryId);
    if (!request.isAssignedTo(riderId)) {
      throw const DeliveryTransitionException(
        'This delivery is not assigned to this rider.',
      );
    }
    return _pickupConfigurations[deliveryId] ??
        const PickupConfiguration(
          requiredMethods: {
            PickupConfirmationMethod.productPhoto,
            PickupConfirmationMethod.farmerConfirmation,
            PickupConfirmationMethod.quantityConfirmation,
            PickupConfirmationMethod.weightConfirmation,
          },
        );
  }

  Future<PickupCompletionResult> _completePickup(
    PickupCompletionCommand command,
  ) async {
    final key = '${command.riderId}|${command.idempotencyKey}';
    final replay = _pickupCompletions[key];
    if (replay != null) return replay;
    final validation = validatePickupCompletion(command, now: _clock());
    if (!validation.isValid) {
      throw DeliveryTransitionException(
        validation.message,
        code: DeliveryErrorCode.invalidProof,
      );
    }
    final request = _requestFor(command.deliveryId);
    final current = _snapshotFor(request);
    if (!request.isAssignedTo(command.riderId)) {
      throw const DeliveryTransitionException(
        'This delivery is not assigned to this rider.',
      );
    }
    final configuration = await _fetchPickupConfiguration(
      deliveryId: command.deliveryId,
      riderId: command.riderId,
    );
    if (configuration.requiredMethods.contains(
          PickupConfirmationMethod.confirmationCode,
        ) &&
        _usedPickupCodes.contains(command.deliveryId)) {
      throw const DeliveryTransitionException(
        'This pickup confirmation code has already been used.',
      );
    }
    if (current.currentStatus != DeliveryStatus.pickupConfirmationRequired) {
      throw const DeliveryTransitionException(
        'Pickup confirmation is not available at this stage.',
      );
    }
    final requiredCapacity = request.requiredCapacityKg;
    final riderCapacity = _riderStates[command.riderId]?.capacityKg;
    if (requiredCapacity != null &&
        riderCapacity != null &&
        requiredCapacity > riderCapacity) {
      throw const DeliveryTransitionException(
        'This product exceeds the Rider vehicle capacity.',
      );
    }
    _validateChecklist(command.checklist, request);
    _validateProofs(command, configuration);
    final proofs = _proofsFor(command);
    final status = await _updateDeliveryStatus(
      DeliveryStatusUpdateCommand(
        deliveryId: command.deliveryId,
        riderId: command.riderId,
        previousStatus: DeliveryStatus.pickupConfirmationRequired,
        newStatus: DeliveryStatus.productPickedUp,
        idempotencyKey: 'pickup-${command.idempotencyKey}',
        location: command.location,
        note: 'Pickup checks completed; buyer notified.',
        proofReference: proofs.isEmpty ? null : proofs.first.secureReference,
      ),
    );
    final proofRequest = status.request.copyWith(
      proofs: [...status.request.proofs, ...proofs],
    );
    final completedStatus = DeliveryStatusSnapshot(
      request: proofRequest,
      currentStatus: status.currentStatus,
      events: status.events,
    );
    _requests[command.deliveryId] = proofRequest;
    _statusSnapshots[command.deliveryId] = completedStatus;
    if (configuration.requiredMethods.contains(
      PickupConfirmationMethod.confirmationCode,
    )) {
      _usedPickupCodes.add(command.deliveryId);
    }
    if (configuration.requiredMethods.contains(
      PickupConfirmationMethod.qrCode,
    )) {
      _usedPickupQrPayloads.add(command.deliveryId);
    }
    final record = PickupCompletionRecord(
      deliveryId: command.deliveryId,
      riderId: command.riderId,
      recordedAt: _clock(),
      location: command.location,
      checklist: command.checklist,
      proofReferences: Map.unmodifiable(command.proofReferences),
      buyerNotified: true,
    );
    _pickupRecords[command.deliveryId] = record;
    final result = PickupCompletionResult(
      status: completedStatus,
      proofReferences: proofs.map((proof) => proof.secureReference).toList(),
      buyerNotified: true,
      record: record,
    );
    _pickupCompletions[key] = result;
    return result;
  }

  Future<PickupProblemReport> _reportPickupProblem(
    PickupProblemReport report,
  ) async {
    final request = _requestFor(report.deliveryId);
    if (!request.isAssignedTo(report.riderId) || !report.location.isValid) {
      throw const DeliveryTransitionException(
        'A valid assigned pickup location is required.',
      );
    }
    if (report.notes.trim().isEmpty) {
      throw const DeliveryTransitionException(
        'Describe the pickup problem before sending it.',
      );
    }
    if (report.photoReferences.any((reference) => !_isProtected(reference))) {
      throw const DeliveryTransitionException(
        'Pickup problem photos must use protected storage.',
      );
    }
    _pickupProblems[report.id] = report;
    _changes.add(null);
    return report;
  }
}
