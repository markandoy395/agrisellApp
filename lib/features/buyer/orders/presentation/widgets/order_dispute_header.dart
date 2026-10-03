import 'package:flutter/material.dart';
import 'package:agresell_app/features/shared/orders/domain/order_dispute.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

import '../styles/order_dispute_styles.dart';

class OrderDisputeHeader extends StatelessWidget {
  const OrderDisputeHeader({required this.order, this.status, super.key});

  final PlacedOrder order;
  final OrderDisputeStatus? status;

  @override
  Widget build(BuildContext context) {
    final isReport = status == null;
    final appearance = status ?? OrderDisputeStatus.pending;
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: OrderDisputeStyles.iconDecoration(appearance),
          child: Icon(
            isReport
                ? Icons.report_problem_outlined
                : OrderDisputeStyles.statusIcon(appearance),
            color: OrderDisputeStyles.statusColor(appearance),
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isReport ? 'Report Produce Issue' : 'Order Goods Dispute',
                style: OrderDisputeStyles.title,
              ),
              const SizedBox(height: 2),
              Text(
                isReport
                    ? 'Order ${order.id} · ${order.title}'
                    : 'Order ${order.id}',
                maxLines: isReport ? 1 : null,
                overflow: isReport ? TextOverflow.ellipsis : null,
                style: OrderDisputeStyles.caption,
              ),
            ],
          ),
        ),
        if (status != null)
          Container(
            padding: OrderDisputeStyles.badgePadding,
            decoration: OrderDisputeStyles.badgeDecoration(appearance),
            child: Text(
              status!.label,
              style: OrderDisputeStyles.badgeText(appearance),
            ),
          ),
      ],
    );
  }
}
