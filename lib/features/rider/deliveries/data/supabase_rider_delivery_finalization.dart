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
        DeliveryConfirmationMethod.handoverPhoto,
        DeliveryConfirmationMethod.recipientName,
        DeliveryConfirmationMethod.gpsLocation,
        DeliveryConfirmationMethod.timestamp,
      },
    );
  }

  Future<DeliveryCompletionResult> _completeDelivery(
    DeliveryCompletionCommand command,
  ) async {
    try {
      if (!command.finalLocation.isValid) {
        throw const DeliveryTransitionException(
          'A valid final location is required.',
        );
      }
      if (command.proofReferences[DeliveryConfirmationMethod.handoverPhoto]
              ?.trim()
              .isEmpty ??
          true) {
        throw const DeliveryTransitionException(
          'Delivery evidence photo is required before completion.',
          code: DeliveryErrorCode.invalidProof,
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
      for (final entry in fileProofs) {
        await _removeLocalProof(entry.value);
      }
      final completed = await _withDisplayProofs(
        await _requiredBundle(command.deliveryId),
      );
      return DeliveryCompletionResult(
        record: _completionRecord(completed, command),
      );
    } on DeliveryDataException catch (error) {
      throw DeliveryTransitionException(
        error.message,
        code: _completionErrorCode(error),
      );
    }
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
        capturedAt: method == DeliveryConfirmationMethod.handoverPhoto
            ? command.evidenceCapturedAt ?? DateTime.now()
            : DateTime.now(),
        latitude: method == DeliveryConfirmationMethod.handoverPhoto
            ? (command.evidenceLocation ?? command.finalLocation).latitude
            : command.finalLocation.latitude,
        longitude: method == DeliveryConfirmationMethod.handoverPhoto
            ? (command.evidenceLocation ?? command.finalLocation).longitude
            : command.finalLocation.longitude,
        confirmedAt: method == DeliveryConfirmationMethod.handoverPhoto
            ? command.evidenceCapturedAt ?? DateTime.now()
            : DateTime.now(),
      ),
    );
  }

  DeliveryErrorCode _completionErrorCode(DeliveryDataException error) {
    return switch (error.type) {
      DeliveryDataFailureType.authentication ||
      DeliveryDataFailureType.authorization =>
        DeliveryErrorCode.unauthorizedOperation,
      DeliveryDataFailureType.offline ||
      DeliveryDataFailureType.timeout => DeliveryErrorCode.networkUnavailable,
      DeliveryDataFailureType.conflict =>
        DeliveryErrorCode.synchronizationConflict,
      DeliveryDataFailureType.validation
          when error.message.toLowerCase().contains('cash') ||
              error.message.toLowerCase().contains('gcash') ||
              error.message.toLowerCase().contains('payment') =>
        DeliveryErrorCode.invalidPayment,
      DeliveryDataFailureType.validation ||
      DeliveryDataFailureType.storage => DeliveryErrorCode.invalidProof,
      DeliveryDataFailureType.database =>
        DeliveryErrorCode.invalidStatusTransition,
    };
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
    final completed = bundles
        .where(
          (item) =>
              item.delivery.deliveryStatus == DeliveryStatus.deliveryCompleted,
        )
        .toList(growable: false);
    final withProofs = await Future.wait(completed.map(_withDisplayProofs));
    return withProofs
        .map((item) => _completedFromBundle(item, riderId))
        .toList(growable: false);
  }

  Future<DeliveryBundle> _withDisplayProofs(DeliveryBundle bundle) async {
    try {
      final proofs = await _dataSource.getDeliveryProofs(
        bundle.delivery.deliveryId,
      );
      final displayProofs = await Future.wait([
        for (final proof in proofs)
          if (proof.type == DeliveryProofType.deliveryPhoto &&
              proof.filePath != null)
            _proofWithSignedUrl(proof)
          else
            Future.value(proof),
      ]);
      return bundle.copyWith(proofs: displayProofs);
    } on DeliveryDataException {
      // Proof previews are display-only and must not turn a successful server
      // completion into a failed delivery action.
      return bundle;
    }
  }

  Future<DeliveryProof> _proofWithSignedUrl(DeliveryProof proof) async {
    try {
      final url = await _dataSource.createProofSignedUrl(proof.filePath!);
      return proof.copyWith(secureReference: url);
    } on DeliveryDataException {
      return proof;
    }
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
