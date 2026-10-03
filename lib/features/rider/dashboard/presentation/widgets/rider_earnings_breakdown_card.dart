import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_analytics_models.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_earnings_styles.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_analytics_formatters.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';

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
    padding: RiderEarningsStyles.breakdownRowPadding,
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: RiderEarningsStyles.breakdownLabelStyle),
        ),
        Text(value, style: RiderEarningsStyles.breakdownValueStyle(color)),
      ],
    ),
  );
}
