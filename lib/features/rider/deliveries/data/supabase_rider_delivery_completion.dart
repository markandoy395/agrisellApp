part of 'rider_delivery_repository.dart';

extension _SupabaseRiderDeliveryCompletion on SupabaseRiderDeliveryRepository {
  Future<DeliveryStatusSnapshot> _updateStatus(
    DeliveryStatusUpdateCommand command,
  ) async {
    const DeliveryTransitionValidator().validate(
      command.previousStatus,
      command.newStatus,
    );
    try {
      if (command.previousStatus.databaseValue ==
          command.newStatus.databaseValue) {
        final current = _snapshot(
          await _requiredBundle(command.deliveryId),
          command.riderId,
        );
        if (!current.request.isAssignedTo(command.riderId)) {
          throw const DeliveryDomainException.unauthorized();
        }
        if (current.currentStatus.databaseValue !=
            command.previousStatus.databaseValue) {
          throw const DeliveryDomainException.synchronizationConflict();
        }
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
    final validation = validatePickupCompletion(command);
    if (!validation.isValid) {
      throw DeliveryTransitionException(
        validation.message,
        code: DeliveryErrorCode.invalidProof,
      );
    }
    try {
      for (final entry in command.proofReferences.entries.where(
        (entry) => entry.key.requiresImage,
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
      await _dataSource.completePickupStatus(
        deliveryId: command.deliveryId,
        previousStatus: bundle.delivery.deliveryStatus,
        idempotencyKey: command.idempotencyKey,
        command: command,
      );
      for (final reference in command.proofReferences.values) {
        await _removeLocalProof(reference);
        _pendingPickupRemoteReferences.remove(reference);
      }
      final snapshot = _snapshot(
        await _requiredBundle(command.deliveryId),
        command.riderId,
      );
      return PickupCompletionResult(
        status: snapshot,
        proofReferences: command.proofReferences.values.toList(),
        buyerNotified: true,
      );
    } on DeliveryDataException catch (error) {
      throw DeliveryTransitionException(
        error.message,
        code: switch (error.type) {
          DeliveryDataFailureType.offline || DeliveryDataFailureType.timeout =>
            DeliveryErrorCode.networkUnavailable,
          DeliveryDataFailureType.authentication ||
          DeliveryDataFailureType.authorization =>
            DeliveryErrorCode.unauthorizedOperation,
          DeliveryDataFailureType.conflict =>
            DeliveryErrorCode.synchronizationConflict,
          DeliveryDataFailureType.storage ||
          DeliveryDataFailureType.validation => DeliveryErrorCode.invalidProof,
          _ => DeliveryErrorCode.invalidStatusTransition,
        },
      );
    }
  }

  Future<void> _savePickupReference(
    PickupCompletionCommand command,
    PickupConfirmationMethod method,
    String reference,
  ) async {
    if (reference.startsWith('protected://')) {
      throw const DeliveryTransitionException(
        'This saved pickup proof has no image. Retake its photo or remove '
        'the optional proof, then complete pickup again.',
        code: DeliveryErrorCode.invalidProof,
      );
    }
    final type = method == PickupConfirmationMethod.farmerSignature
        ? DeliveryProofType.riderSignature
        : DeliveryProofType.productPhoto;
    final remoteReference =
        _pendingPickupRemoteReferences[reference] ??
        await _remoteProofReference(
          reference: reference,
          deliveryId: command.deliveryId,
          stage: DeliveryProofStage.pickup,
          type: type,
        );
    _pendingPickupRemoteReferences[reference] = remoteReference;
    await _dataSource.saveDeliveryProof(
      DeliveryProof(
        id: 'pending-${command.idempotencyKey}-${method.name}',
        deliveryId: command.deliveryId,
        stage: DeliveryProofStage.pickup,
        type: type,
        secureReference: remoteReference,
        filePath: remoteReference,
        remarks: 'pickup_method:${method.name}',
        capturedAt: DateTime.now(),
        latitude: command.location.latitude,
        longitude: command.location.longitude,
        confirmedAt: DateTime.now(),
      ),
    );
  }
}
