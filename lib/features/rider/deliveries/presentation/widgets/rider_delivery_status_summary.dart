import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_transition_validator.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/delivery_status_presentation.dart';

class RiderDeliveryStatusSummary extends StatelessWidget {
  const RiderDeliveryStatusSummary({
    required this.status,
    this.accuracyMeters,
    super.key,
  });

  final DeliveryStatus status;
  final double? accuracyMeters;

  @override
  Widget build(BuildContext context) {
    final next = _nextStatus(status);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AgrisellColors.limeSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(status.icon, size: 18, color: AgrisellColors.authGreen),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current: ${status.displayLabel}',
                    style: const TextStyle(
                      color: AgrisellColors.headingGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    next == null
                        ? 'No further Rider action.'
                        : 'Next: ${next.displayLabel}',
                    style: const TextStyle(
                      color: AgrisellColors.mutedText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (accuracyMeters != null)
                    Text(
                      'GPS accuracy: ${accuracyMeters!.toStringAsFixed(0)} m',
                      style: const TextStyle(
                        color: AgrisellColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DeliveryStatus? _nextStatus(DeliveryStatus value) {
    final index = DeliveryTransitionValidator.normalFlow.indexOf(value);
    if (index < 0 ||
        index == DeliveryTransitionValidator.normalFlow.length - 1) {
      return null;
    }
    return DeliveryTransitionValidator.normalFlow[index + 1];
  }
}
