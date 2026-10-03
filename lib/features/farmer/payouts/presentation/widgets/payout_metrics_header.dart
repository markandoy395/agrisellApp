import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/payouts/domain/farmer_payout.dart';
import 'package:agresell_app/features/shared/payments/price_formatter.dart';

import '../styles/payout_layout_styles.dart';
import '../styles/payout_surface_styles.dart';
import '../styles/payout_text_styles.dart';

class PayoutMetricsHeader extends StatelessWidget {
  const PayoutMetricsHeader({required this.summary, required this.onCashOut});

  final FarmerPayoutSummary summary;
  final VoidCallback onCashOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: PayoutLayoutStyles.metricsPadding,
      color: PayoutSurfaceStyles.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Total Disbursed',
                  amount: formatBasketPeso(summary.totalPaidOut),
                  countText: '${summary.paidCount} completed',
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: AgrisellColors.statusGreenText,
                  backgroundColor: AgrisellColors.statusGreenBackground,
                ),
              ),
              const SizedBox(width: PayoutLayoutStyles.sectionGap),
              Expanded(
                child: _MetricCard(
                  title: 'Pending Payouts',
                  amount: formatBasketPeso(summary.pendingPayouts),
                  countText: '${summary.pendingCount} in transit',
                  icon: Icons.hourglass_top_rounded,
                  iconColor: AgrisellColors.statusOrangeText,
                  backgroundColor: AgrisellColors.statusOrangeBackground,
                ),
              ),
            ],
          ),
          const SizedBox(height: PayoutLayoutStyles.sectionGap),
          SizedBox(
            width: PayoutLayoutStyles.fullWidth,
            child: ElevatedButton.icon(
              onPressed: onCashOut,
              icon: const Icon(
                Icons.payments_rounded,
                size: PayoutLayoutStyles.cashOutIconSize,
              ),
              label: const Text(
                'Request Payout / Cash Out',
                style: PayoutTextStyles.cashOutButton,
              ),
              style: PayoutSurfaceStyles.cashOutButtonStyle,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.amount,
    required this.countText,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  final String title;
  final String amount;
  final String countText;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: PayoutLayoutStyles.metricPadding,
      decoration: PayoutSurfaceStyles.amountPanel(backgroundColor),
      child: Column(
        crossAxisAlignment: PayoutLayoutStyles.alignStart,
        children: [
          Row(
            mainAxisAlignment: PayoutLayoutStyles.spaceBetween,
            children: [
              Text(title, style: PayoutTextStyles.metricLabel(iconColor)),
              Icon(
                icon,
                size: PayoutLayoutStyles.actionIconSize,
                color: iconColor,
              ),
            ],
          ),
          const SizedBox(height: PayoutLayoutStyles.labelGap),
          Text(amount, style: PayoutTextStyles.amount(iconColor)),
          const SizedBox(height: PayoutLayoutStyles.tinyGap),
          Text(countText, style: PayoutTextStyles.mutedLabel),
        ],
      ),
    );
  }
}
