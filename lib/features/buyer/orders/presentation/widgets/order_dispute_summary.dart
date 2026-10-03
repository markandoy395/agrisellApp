import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/orders/domain/order_dispute.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

import '../styles/order_dispute_styles.dart';
import '../utils/order_dispute_helpers.dart';
import 'order_dispute_header.dart';

class OrderDisputeSummary extends StatelessWidget {
  const OrderDisputeSummary({
    required this.order,
    required this.dispute,
    super.key,
  });

  final PlacedOrder order;
  final OrderDispute dispute;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      OrderDisputeHeader(order: order, status: dispute.status),
      const SizedBox(height: 16),
      Container(
        width: double.infinity,
        padding: OrderDisputeStyles.detailsPadding,
        decoration: OrderDisputeStyles.detailsDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow('Claim Category', dispute.category.label),
            const SizedBox(height: 10),
            _DetailRow('Desired Resolution', dispute.requestedResolution.label),
            const SizedBox(height: 10),
            _DetailRow(
              'Reported At',
              formatOrderDisputeDate(dispute.submittedAt),
            ),
            const Divider(height: 20, color: AgrisellColors.borderLine),
            const Text(
              'Buyer Explanation',
              style: OrderDisputeStyles.detailLabel,
            ),
            const SizedBox(height: 4),
            Text(dispute.reason, style: OrderDisputeStyles.explanation),
            if (dispute.resolutionNote != null &&
                dispute.resolutionNote!.trim().isNotEmpty) ...[
              const Divider(height: 20, color: AgrisellColors.borderLine),
              const Text(
                'Administrator Resolution',
                style: OrderDisputeStyles.resolutionLabel,
              ),
              const SizedBox(height: 4),
              Text(
                dispute.resolutionNote!,
                style: OrderDisputeStyles.explanation,
              ),
              if (dispute.resolvedAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Resolved on ${formatOrderDisputeDate(dispute.resolvedAt)}',
                  style: OrderDisputeStyles.caption,
                ),
              ],
            ],
          ],
        ),
      ),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        height: 46,
        child: OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OrderDisputeStyles.closeButton,
          child: const Text('Close', style: OrderDisputeStyles.closeText),
        ),
      ),
    ],
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: OrderDisputeStyles.detailLabel),
      Text(value, style: OrderDisputeStyles.detailValue),
    ],
  );
}
