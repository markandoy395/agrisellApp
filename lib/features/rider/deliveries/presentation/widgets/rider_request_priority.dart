import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';

RiderRequestPriorityStyle riderRequestPriorityStyle(DeliveryPriority priority) {
  return switch (priority) {
    DeliveryPriority.normal => const RiderRequestPriorityStyle(
      label: 'Normal',
      background: AgrisellColors.statusBlueBackground,
      foreground: AgrisellColors.statusBlueText,
    ),
    DeliveryPriority.high => const RiderRequestPriorityStyle(
      label: 'High',
      background: AgrisellColors.statusOrangeBackground,
      foreground: AgrisellColors.statusOrangeText,
    ),
    DeliveryPriority.standard => const RiderRequestPriorityStyle(
      label: 'Standard',
      background: AgrisellColors.statusBlueBackground,
      foreground: AgrisellColors.statusBlueText,
    ),
    DeliveryPriority.scheduled => const RiderRequestPriorityStyle(
      label: 'Scheduled',
      background: AgrisellColors.statusBlueBackground,
      foreground: AgrisellColors.statusBlueText,
    ),
    DeliveryPriority.priority => const RiderRequestPriorityStyle(
      label: 'Priority',
      background: AgrisellColors.statusOrangeBackground,
      foreground: AgrisellColors.statusOrangeText,
    ),
    DeliveryPriority.urgent => const RiderRequestPriorityStyle(
      label: 'Urgent',
      background: AgrisellColors.statusRedBackground,
      foreground: AgrisellColors.statusRedText,
    ),
    DeliveryPriority.sameDay => const RiderRequestPriorityStyle(
      label: 'Same day',
      background: AgrisellColors.statusOrangeBackground,
      foreground: AgrisellColors.statusOrangeText,
    ),
  };
}

class RiderRequestPriorityStyle {
  const RiderRequestPriorityStyle({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;
}
