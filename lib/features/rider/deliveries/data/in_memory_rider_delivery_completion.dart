part of 'rider_delivery_repository.dart';

extension _InMemoryRiderDeliveryCompletion on InMemoryRiderDeliveryRepository {
  Future<DeliveryCompletionConfiguration> _fetchDeliveryConfiguration({
    required String deliveryId,
    required String riderId,
  }) async {
    final request = _requestFor(deliveryId);
    if (!request.isAssignedTo(riderId)) {
      throw const DeliveryTransitionException(
        'This delivery is not assigned to this rider.',
        code: DeliveryErrorCode.unauthorizedOperation,
      );
    }
    return _deliveryConfigurations[deliveryId] ??
        const DeliveryCompletionConfiguration(
          requiredMethods: {
            DeliveryConfirmationMethod.buyerConfirmation,
            DeliveryConfirmationMethod.recipientName,
            DeliveryConfirmationMethod.gpsLocation,
            DeliveryConfirmationMethod.timestamp,
          },
        );
  }

  Future<DeliveryCompletionResult> _completeDelivery(
    DeliveryCompletionCommand command,
  ) async {
    final key = '${command.riderId}|${command.idempotencyKey}';
    final replay = _deliveryCompletions[key];
    if (replay != null) return replay;
    final request = _requestFor(command.deliveryId);
    if (!request.isAssignedTo(command.riderId)) {
      throw const DeliveryTransitionException(
        'This delivery is not assigned to this rider.',
        code: DeliveryErrorCode.unauthorizedOperation,
      );
    }
    final configuration = await _fetchDeliveryConfiguration(
      deliveryId: command.deliveryId,
      riderId: command.riderId,
    );
    final current = _snapshotFor(request);
    if (current.currentStatus != DeliveryStatus.deliveryConfirmationRequired) {
      if (configuration.requiredMethods.contains(
            DeliveryConfirmationMethod.confirmationCode,
          ) &&
          _usedDeliveryCodes.contains(command.deliveryId)) {
        throw const DeliveryTransitionException(
          'This delivery confirmation code has already been used.',
          code: DeliveryErrorCode.invalidProof,
        );
      }
      throw const DeliveryTransitionException(
        'Delivery confirmation is not available at this stage.',
      );
    }
    _validateDeliveryLocation(command, configuration);
    _validateDeliveryProofs(command, configuration);
    final cashCollection = _validateCashCollection(request, command);
    final now = _clock();
    final earning =
        configuration.finalEarning ??
        RiderDeliveryEarningCalculator.calculate(
          estimatedEarning: request.deliveryFee,
          fees: request.feeBreakdown,
        );
    final proofs = _deliveryProofsFor(command, configuration, now);
    final primaryProof = proofs.isEmpty ? null : proofs.first.secureReference;
    final delivered = _eventFor(
      DeliveryStatusUpdateCommand(
        deliveryId: request.id,
        riderId: command.riderId,
        previousStatus: DeliveryStatus.deliveryConfirmationRequired,
        newStatus: DeliveryStatus.productDelivered,
        idempotencyKey: 'delivered-${command.idempotencyKey}',
        location: command.finalLocation,
        note: 'Configured delivery proof accepted.',
        proofReference: primaryProof,
      ),
      current.events.length + 1,
    );
    final completed = _eventFor(
      DeliveryStatusUpdateCommand(
        deliveryId: request.id,
        riderId: command.riderId,
        previousStatus: DeliveryStatus.productDelivered,
        newStatus: DeliveryStatus.deliveryCompleted,
        idempotencyKey: 'completed-${command.idempotencyKey}',
        location: command.finalLocation,
        note: 'Buyer and farmer notified; live tracking stopped.',
        proofReference: primaryProof,
      ),
      current.events.length + 2,
    );
    final events = List<DeliveryStatusEvent>.unmodifiable([
      ...current.events,
      delivered,
      completed,
    ]);
    final updatedRequest = request.copyWith(
      stage: DeliveryStage.completed,
      proofs: [...request.proofs, ...proofs],
      closedAt: completed.timestamp,
    );
    final snapshot = DeliveryStatusSnapshot(
      request: updatedRequest,
      currentStatus: DeliveryStatus.deliveryCompleted,
      events: events,
    );
    final record = DeliveryCompletionRecord(
      request: updatedRequest,
      events: events,
      completedAt: completed.timestamp,
      finalLocation: command.finalLocation,
      proofReferences: Map.unmodifiable(command.proofReferences),
      buyerNotified: true,
      farmerNotified: true,
      recipientName: command.recipientName?.trim(),
      deliveryNotes: command.deliveryNotes?.trim(),
      earningStatus: earning.earningStatus,
      earning: earning,
      cashCollection: cashCollection,
    );
    final result = DeliveryCompletionResult(record: record);
    _requests[request.id] = updatedRequest;
    _statusSnapshots[request.id] = snapshot;
    _completionHistory[request.id] = record;
    _deliveryCompletions[key] = result;
    _removeActiveAssignment(command.riderId, command.deliveryId);
    _markDeliverySecretsUsed(command, configuration);
    _changes.add(null);
    return result;
  }

  Future<List<DeliveryCompletionRecord>> _fetchCompletedDeliveries(
    String riderId,
  ) async => _completionHistory.values
      .where((record) => record.request.isAssignedTo(riderId))
      .toList(growable: false);

  Future<DeliveryDestinationProblemReport> _reportDestinationProblem(
    DeliveryDestinationProblemReport report,
  ) async {
    final request = _requestFor(report.deliveryId);
    if (!request.isAssignedTo(report.riderId) ||
        !report.location.isValid ||
        report.notes.trim().isEmpty) {
      throw const DeliveryTransitionException(
        'A current location and details are required.',
      );
    }
    _destinationProblems.putIfAbsent(report.id, () => report);
    return _destinationProblems[report.id]!;
  }
}
