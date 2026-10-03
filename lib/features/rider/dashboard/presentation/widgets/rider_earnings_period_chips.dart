import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/dashboard/domain/rider_analytics_models.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_earnings_styles.dart';

class RiderEarningsPeriodChips extends StatelessWidget {
  const RiderEarningsPeriodChips({
    required this.selectedPeriod,
    required this.onSelected,
    super.key,
  });

  final RiderAnalyticsPeriod selectedPeriod;
  final ValueChanged<RiderAnalyticsPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: RiderEarningsStyles.chipSpacing,
      runSpacing: RiderEarningsStyles.chipRunSpacing,
      children: [
        for (final period in RiderAnalyticsPeriod.values)
          ChoiceChip(
            label: Text(period.label),
            selected: selectedPeriod == period,
            onSelected: (_) => onSelected(period),
            labelStyle: RiderEarningsStyles.chipLabelStyle,
          ),
      ],
    );
  }
}
