import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_analytics_models.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_analytics_formatters.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';

class RiderEarningsSummaryCard extends StatelessWidget {
  const RiderEarningsSummaryCard({required this.summary, super.key});

  final RiderEarningsSummary summary;

  @override
  Widget build(BuildContext context) => RiderSurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RiderSectionTitle(title: 'Earnings summary'),
        const SizedBox(height: 12),
        Text(
          formatRiderCurrency(summary.netEarnings),
          style: const TextStyle(
            color: AgrisellColors.authGreen,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'Net earnings for the selected period',
          style: TextStyle(
            color: AgrisellColors.mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 14,
          runSpacing: 12,
          children: [
            _EarningsMetric(
              label: 'Gross',
              value: formatRiderCurrency(summary.grossEarnings),
            ),
            _EarningsMetric(
              label: 'Completed',
              value: '${summary.completedDeliveries}',
            ),
            _EarningsMetric(
              label: 'Paid',
              value: formatRiderCurrency(summary.paidEarnings),
            ),
            _EarningsMetric(
              label: 'Pending',
              value: formatRiderCurrency(summary.pendingPayments),
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
        const SizedBox(height: 8),
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

class _EarningsMetric extends StatelessWidget {
  const _EarningsMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 92,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AgrisellColors.headingGreen,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AgrisellColors.mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
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
    padding: const EdgeInsets.symmetric(vertical: 5),
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
