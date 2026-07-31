import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_transition_validator.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/delivery_status_presentation.dart';

class RiderDeliveryActionPanel extends StatelessWidget {
  const RiderDeliveryActionPanel({
    required this.request,
    required this.canAccept,
    required this.isUpdating,
    required this.onAccept,
    required this.onDecline,
    required this.onAdvance,
    required this.onCancel,
    this.currentStatus,
    this.onStatusAdvance,
    this.onPickupConfirmation,
    this.onDeliveryConfirmation,
    this.onDestinationProblem,
    super.key,
  });

  final DeliveryRequest request;
  final bool canAccept;
  final bool isUpdating;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final ValueChanged<DeliveryStage> onAdvance;
  final VoidCallback onCancel;
  final DeliveryStatus? currentStatus;
  final ValueChanged<DeliveryStatus>? onStatusAdvance;
  final VoidCallback? onPickupConfirmation;
  final VoidCallback? onDeliveryConfirmation;
  final VoidCallback? onDestinationProblem;

  @override
  Widget build(BuildContext context) {
    final status = currentStatus;
    if (status != null && request.stage != DeliveryStage.readyForPickup) {
      return _statusActions(status);
    }
    if (request.stage == DeliveryStage.readyForPickup) {
      return Row(
        children: [
          Expanded(
            child: _button('Decline', false, onDecline, enabled: !isUpdating),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _button(
              isUpdating ? 'Processing...' : 'Accept delivery',
              true,
              onAccept,
              enabled: !isUpdating && canAccept,
            ),
          ),
        ],
      );
    }
    final nextStage = request.stage.next;
    if (nextStage == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _button('Mark ${nextStage.label}', true, () => onAdvance(nextStage)),
        const SizedBox(height: 8),
        _button('Report a problem or cancel', false, onCancel),
      ],
    );
  }

  Widget _statusActions(DeliveryStatus status) {
    final index = DeliveryTransitionValidator.normalFlow.indexOf(status);
    final next =
        index < 0 || index >= DeliveryTransitionValidator.normalFlow.length - 1
        ? null
        : DeliveryTransitionValidator.normalFlow[index + 1];
    if (next == null) return const SizedBox.shrink();
    final requiresConfirmation =
        next == DeliveryStatus.productPickedUp ||
        next == DeliveryStatus.productDelivered;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _button(
          isUpdating
              ? 'Updating...'
              : next == DeliveryStatus.productDelivered
              ? 'Confirm product handover'
              : 'Mark ${next.displayLabel}',
          true,
          next == DeliveryStatus.productPickedUp
              ? () => onPickupConfirmation?.call()
              : next == DeliveryStatus.productDelivered
              ? () => onDeliveryConfirmation?.call()
              : () => onStatusAdvance?.call(next),
          enabled:
              !isUpdating &&
              (requiresConfirmation
                  ? next == DeliveryStatus.productPickedUp
                        ? onPickupConfirmation != null
                        : onDeliveryConfirmation != null
                  : onStatusAdvance != null),
        ),
        const SizedBox(height: 8),
        if (status.index >= DeliveryStatus.goingToBuyer.index)
          _button(
            'Destination cannot be found',
            false,
            () => onDestinationProblem?.call(),
            enabled: !isUpdating && onDestinationProblem != null,
          )
        else
          _button('Report a pickup problem', false, () {}, enabled: false),
      ],
    );
  }

  Widget _button(
    String label,
    bool primary,
    VoidCallback onPressed, {
    bool? enabled,
  }) {
    final isEnabled = enabled ?? !isUpdating;
    return SizedBox(
      height: 38,
      child: primary
          ? FilledButton(
              onPressed: isEnabled ? onPressed : null,
              style: FilledButton.styleFrom(
                backgroundColor: AgrisellColors.authGreen,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(label),
            )
          : OutlinedButton(
              onPressed: isEnabled ? onPressed : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: AgrisellColors.statusRedText,
                side: const BorderSide(color: AgrisellColors.statusRedText),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(label),
            ),
    );
  }
}
