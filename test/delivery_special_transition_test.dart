import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_transition_validator.dart';

void main() {
  const validator = DeliveryTransitionValidator();
  const authority = DeliveryTransitionAuthority.authorizedWorkflow;
  final activeStatuses = DeliveryTransitionValidator.normalFlow.where(
    (status) => status != DeliveryStatus.deliveryCompleted,
  );

  test('all authorized cancellation and failure transitions are valid', () {
    for (final status in activeStatuses) {
      expect(
        validator.canTransition(
          status,
          DeliveryStatus.cancelled,
          context: const DeliveryTransitionContext(authority: authority),
        ),
        isTrue,
        reason: '${status.name} -> cancelled',
      );
      expect(
        validator.canTransition(
          status,
          DeliveryStatus.failed,
          context: const DeliveryTransitionContext(
            authority: authority,
            hasApprovedResolution: true,
          ),
        ),
        isTrue,
        reason: '${status.name} -> failed',
      );
    }
  });

  test('all history-preserving dispute transitions are valid', () {
    for (final status in [...activeStatuses, DeliveryStatus.failed]) {
      expect(
        validator.canTransition(
          status,
          DeliveryStatus.disputed,
          context: const DeliveryTransitionContext(
            authority: authority,
            preservesHistory: true,
          ),
        ),
        isTrue,
        reason: '${status.name} -> disputed',
      );
    }
  });

  test('all return and reassignment resolution transitions are valid', () {
    for (final status in [DeliveryStatus.failed, DeliveryStatus.disputed]) {
      expect(
        validator.canTransition(
          status,
          DeliveryStatus.returned,
          context: const DeliveryTransitionContext(
            authority: authority,
            hasReturnProof: true,
            preservesHistory: true,
          ),
        ),
        isTrue,
      );
      expect(
        validator.canTransition(
          status,
          DeliveryStatus.reassigned,
          context: const DeliveryTransitionContext(
            authority: authority,
            preservesHistory: true,
          ),
        ),
        isTrue,
      );
    }
    expect(
      validator.canTransition(
        DeliveryStatus.reassigned,
        DeliveryStatus.reserved,
        context: const DeliveryTransitionContext(
          authority: authority,
          preservesHistory: true,
        ),
      ),
      isTrue,
    );
  });
}
