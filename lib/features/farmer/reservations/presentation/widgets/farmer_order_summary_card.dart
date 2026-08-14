import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_order_workflow_status.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/payments/price_formatter.dart';

class FarmerOrderSummaryCard extends StatelessWidget {
  const FarmerOrderSummaryCard({
    required this.order,
    required this.onTap,
    super.key,
  });

  final PlacedOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 380;
    final buyerName = order.buyerName.trim().isEmpty
        ? 'Buyer name not available'
        : order.buyerName.trim();
    final itemLabel = order.totalQuantity == 1 ? 'item' : 'items';

    return Semantics(
      button: true,
      label: 'Open order ${order.id} details for $buyerName',
      child: Material(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        shadowColor: AgrisellColors.brandBlack.withValues(alpha: 0.08),
        child: InkWell(
          key: ValueKey('farmer-order-card-${order.id}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(compact ? 12 : 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Order #${order.id}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AgrisellColors.mutedText,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FarmerOrderWorkflowStatus(
                      status: order.status,
                      isExpired: order.isExpired,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  buyerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AgrisellColors.headingGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${order.totalQuantity} $itemLabel \u2022 '
                        '${formatBasketPeso(order.total)}',
                        style: const TextStyle(
                          color: AgrisellColors.brandBlack,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 22,
                      color: AgrisellColors.authGreen,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
