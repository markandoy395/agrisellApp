import 'package:agresell_app/features/farmer/reservations/presentation/styles/farmer_order_workflow_status_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

class FarmerOrderWorkflowStatus extends StatelessWidget {
  const FarmerOrderWorkflowStatus({
    required this.status,
    this.isExpired = false,
    super.key,
  });

  final PlacedOrderStatus status;
  final bool isExpired;

  @override
  Widget build(BuildContext context) {
    final color = isExpired
        ? AgrisellColors.statusRedText
        : AgrisellColors.authGreen;
    final label = isExpired
        ? 'Expired'
        : switch (status) {
            PlacedOrderStatus.toShip => 'Awaiting acceptance',
            PlacedOrderStatus.preparing => 'Preparing',
            PlacedOrderStatus.readyForPickup => 'Ready for pickup',
            PlacedOrderStatus.shipping => 'With rider',
            _ => status.label,
          };
    final icon = isExpired
        ? Icons.error_outline_rounded
        : status == PlacedOrderStatus.toShip
        ? Icons.hourglass_top_rounded
        : Icons.task_alt_rounded;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: FarmerOrderWorkflowStatusStyles.containerDecoration(
        isExpired,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(label, style: FarmerOrderWorkflowStatusStyles.labelText(color)),
        ],
      ),
    );
  }
}
