import 'package:flutter/material.dart';

import '../styles/payout_layout_styles.dart';
import '../styles/payout_surface_styles.dart';
import '../styles/payout_text_styles.dart';
import 'payout_history_card.dart';

class PayoutDetailAmount extends StatelessWidget {
  const PayoutDetailAmount({
    required this.label,
    required this.amount,
    required this.statusLabel,
    required this.statusColor,
    required this.backgroundColor,
    super.key,
  });

  final String label;
  final String amount;
  final String statusLabel;
  final Color statusColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: PayoutLayoutStyles.fullWidth,
      padding: PayoutLayoutStyles.cardPadding,
      decoration: PayoutSurfaceStyles.amountPanel(backgroundColor),
      child: Column(
        crossAxisAlignment: PayoutLayoutStyles.alignStart,
        children: [
          Row(
            mainAxisAlignment: PayoutLayoutStyles.spaceBetween,
            children: [
              Text(label, style: PayoutTextStyles.referenceLabel),
              PayoutStatusBadge(
                label: statusLabel,
                color: statusColor,
                backgroundColor: PayoutSurfaceStyles.white,
              ),
            ],
          ),
          const SizedBox(height: PayoutLayoutStyles.labelGap),
          Text(amount, style: PayoutTextStyles.amount(statusColor)),
        ],
      ),
    );
  }
}
