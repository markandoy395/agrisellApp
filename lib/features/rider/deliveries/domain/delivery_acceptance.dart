import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';

class DeliveryAcceptanceCommand {
  const DeliveryAcceptanceCommand({
    required this.requestId,
    required this.riderId,
    required this.idempotencyKey,
  });

  final String requestId;
  final String riderId;
  final String idempotencyKey;
}

enum DeliveryAcceptanceFailure {
  requestNotFound,
  alreadyAssigned,
  expired,
  productNotReady,
  riderNotAllowed,
  riderIneligible,
  riderOffline,
  riderUnavailable,
  locationUnacceptable,
  serviceAreaMismatch,
  vehicleMismatch,
  capacityMismatch,
  batchIncompatible,
  codUnavailable,
  activeDeliveryLimit,
  conflictingAssignment,
  transactionConflict,
  transactionFailed,
  networkTimeout,
  serverError,
  unknown,
}

extension DeliveryAcceptanceFailureDetails on DeliveryAcceptanceFailure {
  String get userMessage => switch (this) {
    DeliveryAcceptanceFailure.requestNotFound =>
      'This delivery request could not be found.',
    DeliveryAcceptanceFailure.alreadyAssigned =>
      'Another Rider has already accepted this delivery.',
    DeliveryAcceptanceFailure.expired => 'This delivery request has expired.',
    DeliveryAcceptanceFailure.productNotReady =>
      'The product is no longer ready for pickup.',
    DeliveryAcceptanceFailure.riderNotAllowed =>
      'Your Rider account is not currently allowed to deliver.',
    DeliveryAcceptanceFailure.riderIneligible =>
      'Your Rider eligibility changed. Refresh your details and try again.',
    DeliveryAcceptanceFailure.riderOffline =>
      'You are Offline. Go Online and Available before accepting.',
    DeliveryAcceptanceFailure.riderUnavailable =>
      'You are no longer Available for a new delivery.',
    DeliveryAcceptanceFailure.locationUnacceptable =>
      'Your current Rider location could not be verified.',
    DeliveryAcceptanceFailure.serviceAreaMismatch =>
      'This delivery is outside your current service area.',
    DeliveryAcceptanceFailure.vehicleMismatch =>
      'Your current vehicle is not compatible with this delivery.',
    DeliveryAcceptanceFailure.capacityMismatch =>
      'Your current vehicle capacity is not sufficient for this delivery.',
    DeliveryAcceptanceFailure.batchIncompatible =>
      'This delivery is not compatible with your current delivery batch.',
    DeliveryAcceptanceFailure.codUnavailable =>
      'Your logistics company does not support Cash on Delivery.',
    DeliveryAcceptanceFailure.activeDeliveryLimit =>
      'You have reached the active-delivery limit.',
    DeliveryAcceptanceFailure.conflictingAssignment =>
      'You already have a conflicting delivery assignment.',
    DeliveryAcceptanceFailure.transactionConflict =>
      'The request changed while it was being accepted. Please refresh.',
    DeliveryAcceptanceFailure.transactionFailed =>
      'Acceptance could not be committed safely. Please try again.',
    DeliveryAcceptanceFailure.networkTimeout =>
      'The server took too long to respond. Refresh before trying again.',
    DeliveryAcceptanceFailure.serverError =>
      'The delivery service is temporarily unavailable.',
    DeliveryAcceptanceFailure.unknown =>
      'The delivery could not be accepted. Please refresh and try again.',
  };

  bool get keepsIdempotencyKey => switch (this) {
    DeliveryAcceptanceFailure.networkTimeout ||
    DeliveryAcceptanceFailure.serverError ||
    DeliveryAcceptanceFailure.unknown => true,
    _ => false,
  };

  bool get canRetry => switch (this) {
    DeliveryAcceptanceFailure.networkTimeout ||
    DeliveryAcceptanceFailure.serverError ||
    DeliveryAcceptanceFailure.transactionConflict ||
    DeliveryAcceptanceFailure.transactionFailed ||
    DeliveryAcceptanceFailure.unknown => true,
    _ => false,
  };
}

class ActiveDeliveryRecord {
  const ActiveDeliveryRecord({
    required this.id,
    required this.requestId,
    required this.riderId,
    required this.acceptedAt,
    required this.estimatedEarning,
  });

  final String id;
  final String requestId;
  final String riderId;
  final DateTime acceptedAt;
  final double estimatedEarning;
}

class DeliveryAcceptanceReceipt {
  const DeliveryAcceptanceReceipt({
    required this.request,
    required this.activeDelivery,
    required this.riderAvailability,
    this.isIdempotentReplay = false,
  });

  final DeliveryRequest request;
  final ActiveDeliveryRecord activeDelivery;
  final RiderAvailability riderAvailability;
  final bool isIdempotentReplay;

  DeliveryAcceptanceReceipt asReplay() => DeliveryAcceptanceReceipt(
    request: request,
    activeDelivery: activeDelivery,
    riderAvailability: riderAvailability,
    isIdempotentReplay: true,
  );
}

class DeliveryAcceptanceException implements Exception {
  const DeliveryAcceptanceException(this.failure);
  final DeliveryAcceptanceFailure failure;
}

class DeliveryAcceptanceOutcome {
  const DeliveryAcceptanceOutcome.success(this.receipt)
    : failure = null,
      message = null;

  const DeliveryAcceptanceOutcome.failure(this.failure, this.message)
    : receipt = null;

  final DeliveryAcceptanceReceipt? receipt;
  final DeliveryAcceptanceFailure? failure;
  final String? message;

  bool get isSuccess => receipt != null;
}
