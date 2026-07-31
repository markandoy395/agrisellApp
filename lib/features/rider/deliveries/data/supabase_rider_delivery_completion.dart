part of 'rider_delivery_repository.dart';

extension _SupabaseRiderDeliveryCompletion on SupabaseRiderDeliveryRepository {
  Future<DeliveryStatusSnapshot> _updateStatus(
    DeliveryStatusUpdateCommand command,
  ) async {
    const DeliveryTransitionValidator().validate(
      command.previousStatus,
      command.newStatus,
    );
    if (command.previousStatus.databaseValue ==
        command.newStatus.databaseValue) {
      final current = _snapshot(
        await _requiredBundle(command.deliveryId),
        command.riderId,
      );
      final event = DeliveryStatusEvent(
        eventId: command.idempotencyKey,
        deliveryId: command.deliveryId,
        previousStatus: command.previousStatus,
        newStatus: command.newStatus,
        riderId: command.riderId,
        timestamp: DateTime.now(),
        latitude: command.location?.latitude,
        longitude: command.location?.longitude,
        note: command.note,
        source: command.source,
        syncStatus: DeliveryEventSyncStatus.synchronized,
      );
      return DeliveryStatusSnapshot(
        request: current.request,
        currentStatus: command.newStatus,
        events: [...current.events, event],
      );
    }
    try {
      await _dataSource.updateDeliveryStatus(
        deliveryId: command.deliveryId,
        previousStatus: command.previousStatus,
        newStatus: command.newStatus,
        idempotencyKey: command.idempotencyKey,
        remarks: command.note ?? command.manualOverrideNotes,
        latitude: command.location?.latitude,
        longitude: command.location?.longitude,
      );
      return _snapshot(
        await _requiredBundle(command.deliveryId),
        command.riderId,
      );
    } on DeliveryDataException catch (error) {
      throw DeliveryTransitionException(
        error.message,
        code: switch (error.type) {
          DeliveryDataFailureType.conflict =>
            DeliveryErrorCode.synchronizationConflict,
          DeliveryDataFailureType.authorization ||
          DeliveryDataFailureType.authentication =>
            DeliveryErrorCode.unauthorizedOperation,
          DeliveryDataFailureType.offline || DeliveryDataFailureType.timeout =>
            DeliveryErrorCode.networkUnavailable,
          _ => DeliveryErrorCode.invalidStatusTransition,
        },
      );
    }
  }

  Future<List<DeliveryStatusSnapshot>> _fetchActiveStatuses(
    String riderId,
  ) async => (await _dataSource.getAssignedDeliveries())
      .where((item) => !item.delivery.deliveryStatus.isTerminal)
      .map((item) => _snapshot(item, riderId))
      .toList(growable: false);

  Future<PickupConfiguration> _pickupConfiguration(
    String deliveryId,
    String riderId,
  ) async {
    await _requiredBundle(deliveryId);
    return const PickupConfiguration(
      requiredMethods: {
        PickupConfirmationMethod.productPhoto,
        PickupConfirmationMethod.quantityConfirmation,
        PickupConfirmationMethod.weightConfirmation,
      },
    );
  }

  Future<PickupCompletionResult> _completePickup(
    PickupCompletionCommand command,
  ) async {
    if (!command.location.isValid || !command.checklist.passes) {
      throw const DeliveryTransitionException(
        'Pickup location and checklist validation are required.',
      );
    }
    for (final entry in command.proofReferences.entries.where(
      (entry) => const {
        PickupConfirmationMethod.productPhoto,
        PickupConfirmationMethod.packagePhoto,
        PickupConfirmationMethod.farmerSignature,
      }.contains(entry.key),
    )) {
      await _savePickupReference(command, entry.key, entry.value);
    }
    if (command.confirmationCode?.trim().isNotEmpty ?? false) {
      await _dataSource.saveConfirmationCode(
        deliveryId: command.deliveryId,
        stage: DeliveryProofStage.pickup,
        code: command.confirmationCode!,
      );
    }
    final bundle = await _requiredBundle(command.deliveryId);
    await _dataSource.updateDeliveryStatus(
      deliveryId: command.deliveryId,
      previousStatus: bundle.delivery.deliveryStatus,
      newStatus: DeliveryStatus.productPickedUp,
      idempotencyKey: command.idempotencyKey,
      remarks: 'Pickup proof accepted.',
      latitude: command.location.latitude,
      longitude: command.location.longitude,
    );
    final snapshot = _snapshot(
      await _requiredBundle(command.deliveryId),
      command.riderId,
    );
    return PickupCompletionResult(
      status: snapshot,
      proofReferences: command.proofReferences.values.toList(),
      buyerNotified: true,
    );
  }

  Future<void> _savePickupReference(
    PickupCompletionCommand command,
    PickupConfirmationMethod method,
    String reference,
  ) async {
    final type = method == PickupConfirmationMethod.farmerSignature
        ? DeliveryProofType.riderSignature
        : DeliveryProofType.productPhoto;
    final remoteReference = await _remoteProofReference(
      reference: reference,
      deliveryId: command.deliveryId,
      stage: DeliveryProofStage.pickup,
      type: type,
    );
    await _dataSource.saveDeliveryProof(
      DeliveryProof(
        id: 'pending-${command.idempotencyKey}-${method.name}',
        deliveryId: command.deliveryId,
        stage: DeliveryProofStage.pickup,
        type: type,
        secureReference: remoteReference,
        filePath: remoteReference,
        capturedAt: DateTime.now(),
        latitude: command.location.latitude,
        longitude: command.location.longitude,
        confirmedAt: DateTime.now(),
      ),
    );
    await _removeLocalProof(reference);
  }
}
