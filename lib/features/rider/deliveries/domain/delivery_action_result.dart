import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';

enum DeliveryActionFailure {
  unavailable,
  alreadyDeclined,
  notAssigned,
  invalidTransition,
  proofRequired,
  offline,
  notEligible,
  unknown,
}

class DeliveryActionResult {
  const DeliveryActionResult.success(this.request)
    : failure = null,
      message = null;

  const DeliveryActionResult.failure({
    required this.failure,
    required this.message,
  }) : request = null;

  final DeliveryRequest? request;
  final DeliveryActionFailure? failure;
  final String? message;

  bool get isSuccess => request != null;
}
