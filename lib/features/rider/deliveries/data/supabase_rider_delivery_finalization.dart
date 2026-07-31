part of 'rider_delivery_repository.dart';

extension _SupabaseRiderDeliveryFinalization
    on SupabaseRiderDeliveryRepository {
  Future<DeliveryCompletionConfiguration> _deliveryConfiguration(
    String deliveryId,
    String riderId,
  ) async {
    await _requiredBundle(deliveryId);
    return const DeliveryCompletionConfiguration(
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
    if (!command.finalLocation.isValid) {
      throw const DeliveryTransitionException(
        'A valid final location is required.',
      );
    }
    final fileProofs = command.proofReferences.entries.where(
      (entry) => const {
        DeliveryConfirmationMethod.buyerSignature,
        DeliveryConfirmationMethod.handoverPhoto,
      }.contains(entry.key),
    );
    for (final entry in fileProofs) {
      await _saveDeliveryReference(command, entry.key, entry.value);
    }
    if (command.confirmationCode?.trim().isNotEmpty ?? false) {
      await _dataSource.saveConfirmationCode(
        deliveryId: command.deliveryId,
        stage: DeliveryProofStage.delivery,
        code: command.confirmationCode!,
      );
    }
    final bundle = await _requiredBundle(command.deliveryId);
    await _dataSource.completeDeliveryStatus(
      deliveryId: command.deliveryId,
      previousStatus: bundle.delivery.deliveryStatus,
      idempotencyKey: command.idempotencyKey,
      remarks: command.deliveryNotes ?? 'Delivery proof accepted.',
      location: command.finalLocation,
      cashCollection: command.cashCollection,
    );
    final completed = await _requiredBundle(command.deliveryId);
    return DeliveryCompletionResult(
      record: _completionRecord(completed, command),
    );
  }

  Future<void> _saveDeliveryReference(
    DeliveryCompletionCommand command,
    DeliveryConfirmationMethod method,
    String reference,
  ) async {
    final type = method == DeliveryConfirmationMethod.buyerSignature
        ? DeliveryProofType.buyerSignature
        : DeliveryProofType.deliveryPhoto;
    final remoteReference = await _remoteProofReference(
      reference: reference,
      deliveryId: command.deliveryId,
      stage: DeliveryProofStage.delivery,
      type: type,
    );
    await _dataSource.saveDeliveryProof(
      DeliveryProof(
        id: 'pending-${command.idempotencyKey}-${method.name}',
        deliveryId: command.deliveryId,
        stage: DeliveryProofStage.delivery,
        type: type,
        secureReference: remoteReference,
        filePath: remoteReference,
        capturedAt: DateTime.now(),
        latitude: command.finalLocation.latitude,
        longitude: command.finalLocation.longitude,
        confirmedAt: DateTime.now(),
      ),
    );
    await _removeLocalProof(reference);
  }

  DeliveryCompletionRecord _completionRecord(
    DeliveryBundle bundle,
    DeliveryCompletionCommand command,
  ) {
    final earning = _earning(bundle.payment);
    return DeliveryCompletionRecord(
      request: _request(bundle, command.riderId),
      events: bundle.history
          .map((item) => _event(item, command.riderId))
          .toList(),
      completedAt:
          bundle.delivery.actualDeliveryAt ?? bundle.delivery.updatedAt,
      finalLocation: command.finalLocation,
      proofReferences: command.proofReferences,
      buyerNotified: true,
      farmerNotified: true,
      recipientName: command.recipientName,
      deliveryNotes: command.deliveryNotes,
      earning: earning,
      earningStatus: earning?.earningStatus ?? DeliveryEarningStatus.pending,
      cashCollection: _cashRecord(bundle, command),
    );
  }

  CashCollectionRecord? _cashRecord(
    DeliveryBundle bundle,
    DeliveryCompletionCommand command,
  ) {
    final submitted = command.cashCollection;
    final requirement = _request(bundle, command.riderId).cashOnDelivery;
    if (submitted == null || requirement == null) return null;
    return CashCollectionRecord(
      amountToCollect: requirement.amountToCollect,
      amountReceived: submitted.amountReceived,
      status: CashCollectionStatus.collected,
      recordedAt: DateTime.now(),
      remittanceRequired: requirement.remittanceRequired,
      notes: submitted.notes,
    );
  }

  DeliveryEarningBreakdown? _earning(DeliveryPayment? payment) {
    if (payment == null) return null;
    return DeliveryEarningBreakdown(
      estimatedEarning: payment.deliveryFee,
      finalEarning: payment.finalEarning,
      earningStatus:
          payment.earningStatus == DeliveryPaymentEarningStatus.approved
          ? DeliveryEarningStatus.finalized
          : DeliveryEarningStatus.pending,
      payoutStatus: payment.payoutStatus == DeliveryPaymentPayoutStatus.paid
          ? DeliveryPayoutStatus.paid
          : DeliveryPayoutStatus.pending,
    );
  }

  Future<List<DeliveryCompletionRecord>> _fetchCompleted(String riderId) async {
    final bundles = await _dataSource.getAssignedDeliveries();
    return bundles
        .where(
          (item) =>
              item.delivery.deliveryStatus == DeliveryStatus.deliveryCompleted,
        )
        .map((item) => _completedFromBundle(item, riderId))
        .toList(growable: false);
  }

  DeliveryCompletionRecord _completedFromBundle(
    DeliveryBundle bundle,
    String riderId,
  ) => DeliveryCompletionRecord(
    request: _request(bundle, riderId),
    events: bundle.history.map((item) => _event(item, riderId)).toList(),
    completedAt: bundle.delivery.actualDeliveryAt ?? bundle.delivery.updatedAt,
    finalLocation: DeliveryStatusLocation(
      latitude: bundle.dropoff?.latitude ?? 0,
      longitude: bundle.dropoff?.longitude ?? 0,
      accuracyMeters: 0,
    ),
    proofReferences: const {},
    buyerNotified: true,
    farmerNotified: true,
  );
}
