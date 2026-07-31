enum DeliveryErrorCode {
  invalidStatusTransition,
  deliveryNotFound,
  deliveryNoLongerAvailable,
  riderUnavailable,
  networkUnavailable,
  unauthorizedOperation,
  invalidProof,
  invalidPayment,
  synchronizationConflict,
}

class DeliveryDomainException implements Exception {
  const DeliveryDomainException(this.message, {required this.code});

  const DeliveryDomainException.invalidTransition([
    String message = 'This delivery status change is not allowed.',
  ]) : this(message, code: DeliveryErrorCode.invalidStatusTransition);

  const DeliveryDomainException.notFound()
    : this(
        'This delivery could not be found.',
        code: DeliveryErrorCode.deliveryNotFound,
      );

  const DeliveryDomainException.noLongerAvailable()
    : this(
        'This delivery is no longer available.',
        code: DeliveryErrorCode.deliveryNoLongerAvailable,
      );

  const DeliveryDomainException.riderUnavailable()
    : this(
        'The rider is not available for this action.',
        code: DeliveryErrorCode.riderUnavailable,
      );

  const DeliveryDomainException.networkUnavailable()
    : this(
        'A network connection is required. Try again when online.',
        code: DeliveryErrorCode.networkUnavailable,
      );

  const DeliveryDomainException.unauthorized()
    : this(
        'You are not authorized to update this delivery.',
        code: DeliveryErrorCode.unauthorizedOperation,
      );

  const DeliveryDomainException.invalidProof()
    : this(
        'Valid delivery proof is required.',
        code: DeliveryErrorCode.invalidProof,
      );

  const DeliveryDomainException.synchronizationConflict()
    : this(
        'This delivery changed elsewhere. Refresh and try again.',
        code: DeliveryErrorCode.synchronizationConflict,
      );

  final DeliveryErrorCode code;
  final String message;

  @override
  String toString() => message;
}

class DeliveryTransitionException extends DeliveryDomainException {
  const DeliveryTransitionException(
    super.message, {
    super.code = DeliveryErrorCode.invalidStatusTransition,
  });
}
