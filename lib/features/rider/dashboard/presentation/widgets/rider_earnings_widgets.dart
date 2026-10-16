import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_analytics_models.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_earnings_styles.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_analytics_formatters.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';
import 'package:agresell_app/features/shared/widgets/metrics/summary_metric.dart';

export 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_earnings_breakdown_card.dart';

class RiderEarningsSummaryCard extends StatelessWidget {
  const RiderEarningsSummaryCard({
    required this.summary,
    this.onCashOut,
    this.onManageMethods,
    super.key,
  });

  final RiderEarningsSummary summary;
  final VoidCallback? onCashOut;
  final VoidCallback? onManageMethods;

  @override
  Widget build(BuildContext context) => RiderSurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RiderSectionTitle(
          title: 'Earnings summary',
          action: (onCashOut != null || onManageMethods != null)
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onManageMethods != null)
                      TextButton.icon(
                        onPressed: onManageMethods,
                        icon: const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 13,
                          color: AgrisellColors.authGreen,
                        ),
                        label: const Text(
                          'Methods',
                          style: RiderEarningsStyles.manageMethodsTextStyle,
                        ),
                        style: RiderEarningsStyles.manageMethodsButtonStyle,
                      ),
                    if (onManageMethods != null && onCashOut != null)
                      const SizedBox(width: 6),
                    if (onCashOut != null)
                      ElevatedButton.icon(
                        onPressed: onCashOut,
                        icon: const Icon(
                          Icons.payments_rounded,
                          size: 13,
                          color: AgrisellColors.surface,
                        ),
                        label: const Text(
                          'Cash Out',
                          style: RiderEarningsStyles.cashOutTextStyle,
                        ),
                        style: RiderEarningsStyles.cashOutButtonStyle,
                      ),
                  ],
                )
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          formatRiderCurrency(summary.netEarnings),
          style: RiderEarningsStyles.netEarningsStyle,
        ),
        const SizedBox(height: 2),
        const Text(
          'Net earnings for the selected period',
          style: RiderEarningsStyles.netEarningsSubtextStyle,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            SummaryMetric(
              label: 'Gross',
              value: formatRiderCurrency(summary.grossEarnings),
              width: 88,
            ),
            SummaryMetric(
              label: 'Completed',
              value: '${summary.completedDeliveries}',
              width: 88,
            ),
            SummaryMetric(
              label: 'Paid',
              value: formatRiderCurrency(summary.paidEarnings),
              width: 88,
            ),
            SummaryMetric(
              label: 'Pending',
              value: formatRiderCurrency(summary.pendingPayments),
              width: 88,
            ),
          ],
        ),
      ],
    ),
  );
}
