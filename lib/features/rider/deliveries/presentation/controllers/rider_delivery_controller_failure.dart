part of 'rider_delivery_controller.dart';

DeliveryActionFailure _legacyFailureFor(DeliveryErrorCode code) {
  return switch (code) {
    DeliveryErrorCode.invalidStatusTransition =>
      DeliveryActionFailure.invalidTransition,
    DeliveryErrorCode.deliveryNotFound ||
    DeliveryErrorCode.deliveryNoLongerAvailable =>
      DeliveryActionFailure.unavailable,
    DeliveryErrorCode.riderUnavailable => DeliveryActionFailure.notEligible,
    DeliveryErrorCode.networkUnavailable => DeliveryActionFailure.offline,
    DeliveryErrorCode.unauthorizedOperation =>
      DeliveryActionFailure.notAssigned,
    DeliveryErrorCode.invalidProof ||
    DeliveryErrorCode.invalidPayment => DeliveryActionFailure.proofRequired,
    DeliveryErrorCode.synchronizationConflict => DeliveryActionFailure.unknown,
  };
}
