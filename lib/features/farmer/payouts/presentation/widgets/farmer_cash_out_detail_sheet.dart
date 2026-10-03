import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/payouts/domain/farmer_cash_out_request.dart';
import 'package:agresell_app/features/shared/payments/price_formatter.dart';

import '../styles/payout_surface_styles.dart';
import '../utils/payout_date_formatter.dart';
import 'payout_detail_layout.dart';

class FarmerCashOutDetailSheet extends StatelessWidget {
  const FarmerCashOutDetailSheet({required this.request, super.key});

  final FarmerCashOutRequest request;

  @override
  Widget build(BuildContext context) {
    final statusColor = PayoutSurfaceStyles.cashOutStatusColor(
      request.isPaid,
      request.isRejected,
    );

    return PayoutDetailLayout(
      title: 'Cash-Out Request Details',
      amountLabel: 'Requested Amount',
      amount: formatBasketPeso(request.amount),
      statusLabel: request.statusLabel,
      statusColor: statusColor,
      backgroundColor: PayoutSurfaceStyles.detailBackground(request.isPaid),
      sectionTitle: 'Withdrawal Information',
      children: [
        PayoutSummaryLine(label: 'Payout Method', value: request.methodLabel),
        PayoutSummaryLine(label: 'Account Name', value: request.accountName),
        PayoutSummaryLine(
          label: 'Account Number',
          value: request.accountNumber,
        ),
        if (request.bankName.isNotEmpty)
          PayoutSummaryLine(label: 'Bank Name', value: request.bankName),
        if (request.createdAt != null)
          PayoutSummaryLine(
            label: 'Requested At',
            value: formatPayoutDateTime(request.createdAt),
          ),
        if (request.notes.isNotEmpty)
          PayoutSummaryLine(label: 'Notes', value: request.notes),
        if (request.rejectionReason.isNotEmpty)
          PayoutSummaryLine(
            label: 'Rejection Reason',
            value: request.rejectionReason,
          ),
      ],
    );
  }
}
