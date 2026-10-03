part of 'rider_delivery_repository.dart';

extension _SupabaseRiderDeliveryRecords on SupabaseRiderDeliveryRepository {
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
