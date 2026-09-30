import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_analytics_models.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_analytics_formatters.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';
import 'package:agresell_app/features/shared/widgets/metrics/summary_metric.dart';

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
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AgrisellColors.authGreen,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    if (onManageMethods != null && onCashOut != null)
                      const SizedBox(width: 6),
                    if (onCashOut != null)
                      ElevatedButton.icon(
                        onPressed: onCashOut,
                        icon: const Icon(
                          Icons.payments_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Cash Out',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AgrisellColors.authGreen,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 0,
                        ),
                      ),
                  ],
                )
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          formatRiderCurrency(summary.netEarnings),
          style: const TextStyle(
            color: AgrisellColors.authGreen,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Net earnings for the selected period',
          style: TextStyle(
            color: AgrisellColors.mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
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

class RiderEarningsBreakdownCard extends StatelessWidget {
  const RiderEarningsBreakdownCard({required this.summary, super.key});

  final RiderEarningsSummary summary;

  @override
  Widget build(BuildContext context) => RiderSurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RiderSectionTitle(title: 'Breakdown'),
        const SizedBox(height: 6),
        _BreakdownRow(
          label: 'Delivery fees',
          value: formatRiderCurrency(summary.deliveryEarnings),
        ),
        _BreakdownRow(
          label: 'Waiting fees',
          value: formatRiderCurrency(summary.waitingFees),
        ),
        _BreakdownRow(
          label: 'Return fees',
          value: formatRiderCurrency(summary.returnFees),
        ),
        _BreakdownRow(
          label: 'Incentives',
          value: formatRiderCurrency(summary.incentives),
        ),
        _BreakdownRow(
          label: 'Bonuses',
          value: formatRiderCurrency(summary.bonuses),
        ),
        _BreakdownRow(
          label: 'Deductions',
          value: '-${formatRiderCurrency(summary.deductions)}',
          color: AgrisellColors.statusRedText,
        ),
        _BreakdownRow(
          label: 'Penalties',
          value: '-${formatRiderCurrency(summary.penalties)}',
          color: AgrisellColors.statusRedText,
        ),
      ],
    ),
  );
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2.5),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AgrisellColors.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color ?? AgrisellColors.headingGreen,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}
