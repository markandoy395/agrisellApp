import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/payouts/domain/farmer_payout.dart';
import 'package:agresell_app/features/shared/payments/price_formatter.dart';

import '../styles/payout_surface_styles.dart';
import '../utils/payout_date_formatter.dart';
import 'payout_detail_layout.dart';

class FarmerPayoutDetailSheet extends StatelessWidget {
  const FarmerPayoutDetailSheet({required this.payout, super.key});

  final FarmerPayout payout;

  @override
  Widget build(BuildContext context) {
    final statusColor = PayoutSurfaceStyles.payoutStatusColor(payout.isPaid);

    return PayoutDetailLayout(
      title: 'Disbursement Details',
      amountLabel: 'Net Payout Amount',
      amount: formatBasketPeso(payout.amount),
      statusLabel: payout.status.label,
      statusColor: statusColor,
      backgroundColor: PayoutSurfaceStyles.detailBackground(payout.isPaid),
      sectionTitle: 'Disbursement Breakdown',
      children: [
        PayoutSummaryLine(
          label: 'Order ID',
          value: payout.clientOrderId.isNotEmpty
              ? payout.clientOrderId
              : 'ORD-${payout.orderId}',
        ),
        PayoutSummaryLine(label: 'Customer', value: payout.buyerName),
        PayoutSummaryLine(
          label: 'Gross Order Total',
          value: formatBasketPeso(payout.orderTotal),
        ),
        PayoutSummaryLine(
          label: 'Net Disbursed',
          value: formatBasketPeso(payout.amount),
        ),
        if (payout.reference.isNotEmpty)
          PayoutSummaryLine(label: 'Payout Reference', value: payout.reference),
        if (payout.paidAt != null)
          PayoutSummaryLine(
            label: 'Paid At',
            value: formatPayoutDateTime(payout.paidAt),
          ),
        if (payout.failureReason.isNotEmpty)
          PayoutSummaryLine(label: 'Failure Note', value: payout.failureReason),
      ],
    );
  }
}
