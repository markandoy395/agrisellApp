part of 'rider_delivery_repository.dart';

extension _InMemoryRiderDeliveryCompletionValidation
    on InMemoryRiderDeliveryRepository {
  CashCollectionRecord? _validateCashCollection(
    DeliveryRequest request,
    DeliveryCompletionCommand command,
  ) {
    if (!request.isCashOnDelivery) return null;
    final requirement = request.cashOnDelivery;
    if (requirement == null) {
      throw const DeliveryTransitionException(
        'The server-authoritative cash amount is unavailable.',
        code: DeliveryErrorCode.invalidPayment,
      );
    }
    final submission = command.cashCollection;
    if (requirement.hasAuthorizedException) {
      return CashCollectionRecord(
        amountToCollect: requirement.amountToCollect,
        amountReceived: submission?.amountReceived ?? 0,
        status: CashCollectionStatus.exceptionApproved,
        recordedAt: _clock(),
        remittanceRequired: requirement.remittanceRequired,
        issue: submission?.issue,
        notes: submission?.notes?.trim(),
        authorizedExceptionReference: requirement.authorizedExceptionReference,
      );
    }
    if (submission == null) {
      throw const DeliveryTransitionException(
        'Cash collection must be confirmed before completion.',
        code: DeliveryErrorCode.invalidPayment,
      );
    }
    final difference = (submission.amountReceived - requirement.amountToCollect)
        .abs();
    if (submission.issue != null ||
        !submission.collectionConfirmed ||
        difference > 0.009) {
      _cashCollectionIssues[request.id] = CashCollectionRecord(
        amountToCollect: requirement.amountToCollect,
        amountReceived: submission.amountReceived,
        status: CashCollectionStatus.pending,
        recordedAt: _clock(),
        remittanceRequired: requirement.remittanceRequired,
        issue: submission.issue ?? CashCollectionIssue.amountMismatch,
        notes: submission.notes?.trim(),
      );
      throw const DeliveryTransitionException(
        'The required cash amount has not been confirmed.',
        code: DeliveryErrorCode.invalidPayment,
      );
    }
    return CashCollectionRecord(
      amountToCollect: requirement.amountToCollect,
      amountReceived: submission.amountReceived,
      status: CashCollectionStatus.collected,
      recordedAt: _clock(),
      remittanceRequired: requirement.remittanceRequired,
      notes: submission.notes?.trim(),
    );
  }

  void _validateDeliveryLocation(
    DeliveryCompletionCommand command,
    DeliveryCompletionConfiguration configuration,
  ) {
    final location = command.finalLocation;
    final timestamp = location.timestamp;
    final age = timestamp == null ? null : _clock().difference(timestamp);
    if (!location.isValid ||
        location.isApproximate ||
        timestamp == null ||
        location.accuracyMeters > configuration.maxAccuracyMeters ||
        age!.isNegative ||
        age > configuration.maxLocationAge) {
      throw const DeliveryTransitionException(
        'A current, precise delivery location is required.',
        code: DeliveryErrorCode.invalidProof,
      );
    }
  }
}
