import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/payouts/domain/farmer_payout.dart';
import 'package:agresell_app/features/shared/payments/price_formatter.dart';

import '../styles/payout_layout_styles.dart';
import '../styles/payout_surface_styles.dart';
import '../styles/payout_text_styles.dart';
import '../utils/payout_date_formatter.dart';
import 'farmer_payout_detail_sheet.dart';
import 'payout_card_amount_row.dart';
import 'payout_history_card.dart';
import 'payout_reference_row.dart';

class FarmerPayoutCard extends StatelessWidget {
  const FarmerPayoutCard({required this.payout});

  final FarmerPayout payout;

  void _openDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AgrisellColors.surface,
      shape: PayoutSurfaceStyles.detailSheetShape,
      builder: (_) => FarmerPayoutDetailSheet(payout: payout),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = PayoutSurfaceStyles.payoutStatusColor(payout.isPaid);
    final statusBg = PayoutSurfaceStyles.cardStatusBackground(
      payout.isPaid,
      payout.isFailed,
    );

    return PayoutHistoryCard(
      onTap: () => _openDetails(context),
      child: Column(
        crossAxisAlignment: PayoutLayoutStyles.alignStart,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Order: ${payout.clientOrderId.isNotEmpty ? payout.clientOrderId : 'ORD-${payout.orderId}'}',
                  style: PayoutTextStyles.orderLabel,
                ),
              ),
              PayoutStatusBadge(
                label: payout.status.label,
                color: statusColor,
                backgroundColor: statusBg,
              ),
            ],
          ),
          const SizedBox(height: PayoutLayoutStyles.contentGap),
          PayoutCardAmountRow(
            amountLabel: 'Net Payout',
            amount: formatBasketPeso(payout.amount),
            date: formatPayoutDate(
              payout.paidAt ?? payout.approvedAt ?? payout.createdAt,
            ),
            description: 'Customer: ${payout.buyerName}',
          ),
          if (payout.reference.isNotEmpty) ...[
            const SizedBox(height: PayoutLayoutStyles.contentGap),
            PayoutReferenceRow(reference: payout.reference),
          ],
        ],
      ),
    );
  }
}
