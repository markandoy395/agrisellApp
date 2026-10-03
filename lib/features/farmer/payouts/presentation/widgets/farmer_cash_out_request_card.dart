import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/payouts/domain/farmer_cash_out_request.dart';
import 'package:agresell_app/features/shared/payments/price_formatter.dart';

import '../styles/payout_layout_styles.dart';
import '../styles/payout_surface_styles.dart';
import '../styles/payout_text_styles.dart';
import '../utils/payout_date_formatter.dart';
import 'farmer_cash_out_detail_sheet.dart';
import 'payout_card_amount_row.dart';
import 'payout_history_card.dart';

class FarmerCashOutRequestCard extends StatelessWidget {
  const FarmerCashOutRequestCard({required this.request});

  final FarmerCashOutRequest request;

  void _openDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AgrisellColors.surface,
      shape: PayoutSurfaceStyles.detailSheetShape,
      builder: (_) => FarmerCashOutDetailSheet(request: request),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = PayoutSurfaceStyles.cashOutStatusColor(
      request.isPaid,
      request.isRejected,
    );
    final statusBg = PayoutSurfaceStyles.cardStatusBackground(
      request.isPaid,
      request.isRejected,
    );

    return PayoutHistoryCard(
      onTap: () => _openDetails(context),
      isCashOut: true,
      child: Column(
        crossAxisAlignment: PayoutLayoutStyles.alignStart,
        children: [
          Row(
            children: [
              Container(
                padding: PayoutLayoutStyles.cashOutTagPadding,
                decoration: PayoutSurfaceStyles.cashOutTag,
                child: const Text(
                  'Cash Out',
                  style: PayoutTextStyles.cashOutTag,
                ),
              ),
              const SizedBox(width: PayoutLayoutStyles.inlineGap),
              Expanded(
                child: Text(
                  request.methodLabel,
                  style: PayoutTextStyles.orderLabel,
                ),
              ),
              PayoutStatusBadge(
                label: request.statusLabel,
                color: statusColor,
                backgroundColor: statusBg,
              ),
            ],
          ),
          const SizedBox(height: PayoutLayoutStyles.contentGap),
          PayoutCardAmountRow(
            amountLabel: 'Requested Amount',
            amount: formatBasketPeso(request.amount),
            date: formatPayoutDate(request.createdAt),
            description: 'Account: ${request.accountName}',
          ),
        ],
      ),
    );
  }
}
