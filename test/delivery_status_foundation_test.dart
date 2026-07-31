import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery_errors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_transition_validator.dart';

void main() {
  const validator = DeliveryTransitionValidator();

  test('every normal delivery transition is valid', () {
    final flow = DeliveryTransitionValidator.normalFlow;
    for (var index = 0; index < flow.length - 1; index++) {
      expect(
        validator.canTransition(flow[index], flow[index + 1]),
        isTrue,
        reason: '${flow[index].name} -> ${flow[index + 1].name}',
      );
    }
  });

  test('skipped, reversed, and same-state transitions are invalid', () {
    expect(
      validator.canTransition(
        DeliveryStatus.available,
        DeliveryStatus.accepted,
      ),
      isFalse,
    );
    expect(
      validator.canTransition(
        DeliveryStatus.productPickedUp,
        DeliveryStatus.pickupConfirmationRequired,
      ),
      isFalse,
    );
    expect(
      validator.canTransition(
        DeliveryStatus.goingToBuyer,
        DeliveryStatus.goingToBuyer,
      ),
      isFalse,
    );
  });

  test('completed delivery is immutable for every authority', () {
    for (final next in DeliveryStatus.values) {
      expect(
        validator.canTransition(
          DeliveryStatus.deliveryCompleted,
          next,
          context: const DeliveryTransitionContext(
            authority: DeliveryTransitionAuthority.authorizedWorkflow,
            hasReturnProof: true,
            hasApprovedResolution: true,
            preservesHistory: true,
          ),
        ),
        isFalse,
      );
    }
  });

  test('special resolutions require authority, proof, and history', () {
    const authorized = DeliveryTransitionAuthority.authorizedWorkflow;
    expect(
      validator.canTransition(
        DeliveryStatus.goingToPickup,
        DeliveryStatus.failed,
        context: const DeliveryTransitionContext(authority: authorized),
      ),
      isFalse,
    );
    expect(
      validator.canTransition(
        DeliveryStatus.goingToPickup,
        DeliveryStatus.failed,
        context: const DeliveryTransitionContext(
          authority: authorized,
          hasApprovedResolution: true,
        ),
      ),
      isTrue,
    );
    expect(
      validator.canTransition(
        DeliveryStatus.failed,
        DeliveryStatus.returned,
        context: const DeliveryTransitionContext(
          authority: authorized,
          preservesHistory: true,
        ),
      ),
      isFalse,
    );
    expect(
      validator.canTransition(
        DeliveryStatus.failed,
        DeliveryStatus.returned,
        context: const DeliveryTransitionContext(
          authority: authorized,
          hasReturnProof: true,
          preservesHistory: true,
        ),
      ),
      isTrue,
    );
    expect(
      validator.canTransition(
        DeliveryStatus.failed,
        DeliveryStatus.reassigned,
        context: const DeliveryTransitionContext(
          authority: authorized,
          preservesHistory: true,
        ),
      ),
      isTrue,
    );
    expect(
      validator.canTransition(
        DeliveryStatus.disputed,
        DeliveryStatus.reassigned,
        context: const DeliveryTransitionContext(authority: authorized),
      ),
      isFalse,
    );
  });

  test('cancelled and returned deliveries cannot rejoin normal flow', () {
    const context = DeliveryTransitionContext(
      authority: DeliveryTransitionAuthority.authorizedWorkflow,
      hasReturnProof: true,
      preservesHistory: true,
    );
    expect(
      validator.canTransition(
        DeliveryStatus.cancelled,
        DeliveryStatus.reserved,
        context: context,
      ),
      isFalse,
    );
    expect(
      validator.canTransition(
        DeliveryStatus.returned,
        DeliveryStatus.reserved,
        context: context,
      ),
      isFalse,
    );
  });

  test('invalid validation throws the centralized typed error', () {
    expect(
      () => validator.validate(
        DeliveryStatus.available,
        DeliveryStatus.productPickedUp,
      ),
      throwsA(
        isA<DeliveryDomainException>().having(
          (error) => error.code,
          'code',
          DeliveryErrorCode.invalidStatusTransition,
        ),
      ),
    );
  });

  test('statuses serialize and accept legacy backend aliases', () {
    for (final status in DeliveryStatus.values) {
      expect(DeliveryStatus.fromBackendValue(status.backendValue), status);
    }
    const aliases = <String, DeliveryStatus>{
      'readyForPickup': DeliveryStatus.available,
      'pickedUp': DeliveryStatus.productPickedUp,
      'goingToDelivery': DeliveryStatus.goingToBuyer,
      'arrivedAtDelivery': DeliveryStatus.arrivedAtDelivery,
      'delivered': DeliveryStatus.productDelivered,
      'completed': DeliveryStatus.deliveryCompleted,
    };
    for (final alias in aliases.entries) {
      expect(DeliveryStatus.fromBackendValue(alias.key), alias.value);
    }
  });
}
