import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_order_workflow_status.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_order_buyer_summary.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_order_payment_panel.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_order_workflow_guidance.dart';
import 'package:agresell_app/features/shared/orders/presentation/widgets/order_acceptance_deadline_card.dart';

class FarmerOrderWorkflowCard extends StatelessWidget {
  const FarmerOrderWorkflowCard({
    required this.order,
    required this.controller,
    super.key,
  });

  final PlacedOrder order;
  final OrderController controller;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final action = _actionFor(controller);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(width < 380 ? 12 : 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AgrisellColors.mutedText,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                FarmerOrderWorkflowStatus(
                  status: order.status,
                  isExpired: order.isExpired,
                ),
              ],
            ),
            const SizedBox(height: 12),
            FarmerOrderBuyerSummary(order: order),
            const SizedBox(height: 8),
            OrderAcceptanceDeadlineCard(
              order: order,
              audience: OrderDeadlineAudience.farmer,
            ),
            if (order.acceptanceExpiresAt != null &&
                (order.isExpired || order.status == PlacedOrderStatus.toShip))
              const SizedBox(height: 8),
            const Divider(height: 1, color: AgrisellColors.borderLine),
            const SizedBox(height: 7),
            for (final item in order.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  '${item.productName}  •  ${item.quantity} ${item.unit}',
                  style: const TextStyle(
                    color: AgrisellColors.brandBlack,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            FarmerOrderPaymentPanel(order: order),
            const SizedBox(height: 9),
            if (action != null)
              SizedBox(
                width: double.infinity,
                height: 40,
                child: FilledButton.icon(
                  onPressed: () => _runAction(context, action),
                  style: FilledButton.styleFrom(
                    backgroundColor: AgrisellColors.authGreen,
                    foregroundColor: AgrisellColors.surface,
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(action.icon, size: 16),
                  label: Text(action.label),
                ),
              )
            else
              FarmerOrderWorkflowGuidance(order: order),
          ],
        ),
      ),
    );
  }

  Future<void> _runAction(BuildContext context, _WorkflowAction action) async {
    try {
      await action.onPressed();
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showAppSnackBar(SnackBar(content: Text(action.successMessage)));
    } on Object catch (error) {
      if (!context.mounted) return;
      final detail = error
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('Bad state: ', '')
          .trim();
      ScaffoldMessenger.of(context).showAppSnackBar(
        SnackBar(
          content: Text(
            detail.isEmpty
                ? 'The order update could not be saved. Try again.'
                : detail,
          ),
        ),
      );
    }
  }

  _WorkflowAction? _actionFor(OrderController controller) {
    return switch (order.status) {
      PlacedOrderStatus.toShip
          when order.payment.allowsOrderAcceptance &&
              !order.isAcceptanceOverdue =>
        _WorkflowAction(
          label: 'Accept order',
          icon: Icons.verified_outlined,
          successMessage: 'Order accepted and the buyer was notified.',
          onPressed: () => controller.acceptOrder(order.id),
        ),
      PlacedOrderStatus.preparing => _WorkflowAction(
        label: 'Mark ready for pickup',
        icon: Icons.inventory_2_outlined,
        successMessage: 'Order marked ready for rider pickup.',
        onPressed: () => controller.markReadyForPickup(order.id),
      ),
      _ => null,
    };
  }
}

class _WorkflowAction {
  const _WorkflowAction({
    required this.label,
    required this.icon,
    required this.successMessage,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final String successMessage;
  final Future<void> Function() onPressed;
}
