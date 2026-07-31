import 'package:agresell_app/features/rider/deliveries/domain/delivery_errors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';

enum DeliveryTransitionAuthority { rider, authorizedWorkflow }

class DeliveryTransitionContext {
  const DeliveryTransitionContext({
    this.authority = DeliveryTransitionAuthority.rider,
    this.hasReturnProof = false,
    this.hasApprovedResolution = false,
    this.preservesHistory = false,
  });

  final DeliveryTransitionAuthority authority;
  final bool hasReturnProof;
  final bool hasApprovedResolution;
  final bool preservesHistory;

  bool get isAuthorizedWorkflow =>
      authority == DeliveryTransitionAuthority.authorizedWorkflow;
}

class DeliveryTransitionValidator {
  const DeliveryTransitionValidator();

  static const normalFlow = <DeliveryStatus>[
    DeliveryStatus.available,
    DeliveryStatus.reserved,
    DeliveryStatus.accepted,
    DeliveryStatus.goingToPickup,
    DeliveryStatus.arrivedAtPickup,
    DeliveryStatus.waitingForProduct,
    DeliveryStatus.pickupConfirmationRequired,
    DeliveryStatus.productPickedUp,
    DeliveryStatus.goingToBuyer,
    DeliveryStatus.arrivedAtDelivery,
    DeliveryStatus.waitingForBuyer,
    DeliveryStatus.deliveryConfirmationRequired,
    DeliveryStatus.productDelivered,
    DeliveryStatus.deliveryCompleted,
  ];

  bool canTransition(
    DeliveryStatus from,
    DeliveryStatus to, {
    DeliveryTransitionContext context = const DeliveryTransitionContext(),
  }) {
    if (from == DeliveryStatus.deliveryCompleted || from == to) return false;
    if (from == DeliveryStatus.pending && to == DeliveryStatus.available) {
      return true;
    }
    final normalIndex = normalFlow.indexOf(from);
    if (normalIndex >= 0 &&
        normalIndex + 1 < normalFlow.length &&
        normalFlow[normalIndex + 1] == to) {
      return true;
    }
    return _canResolveSpecialStatus(from, to, context);
  }

  void validate(
    DeliveryStatus from,
    DeliveryStatus to, {
    DeliveryTransitionContext context = const DeliveryTransitionContext(),
  }) {
    if (canTransition(from, to, context: context)) return;
    throw DeliveryTransitionException(
      'The delivery cannot move from ${from.backendValue} '
      'to ${to.backendValue}.',
    );
  }

  bool _canResolveSpecialStatus(
    DeliveryStatus from,
    DeliveryStatus to,
    DeliveryTransitionContext context,
  ) {
    if (!context.isAuthorizedWorkflow ||
        from == DeliveryStatus.cancelled ||
        from == DeliveryStatus.returned) {
      return false;
    }
    if (to == DeliveryStatus.cancelled) {
      return from.isNormalFlow && from != DeliveryStatus.deliveryCompleted;
    }
    if (to == DeliveryStatus.failed) {
      return context.hasApprovedResolution &&
          from.isNormalFlow &&
          from != DeliveryStatus.deliveryCompleted;
    }
    if (to == DeliveryStatus.disputed) {
      return context.preservesHistory &&
          (from.isNormalFlow || from == DeliveryStatus.failed);
    }
    if (to == DeliveryStatus.returned) {
      return context.hasReturnProof &&
          context.preservesHistory &&
          (from == DeliveryStatus.failed || from == DeliveryStatus.disputed);
    }
    if (to == DeliveryStatus.reassigned) {
      return context.preservesHistory &&
          (from == DeliveryStatus.failed || from == DeliveryStatus.disputed);
    }
    return from == DeliveryStatus.reassigned &&
        to == DeliveryStatus.reserved &&
        context.preservesHistory;
  }
}
