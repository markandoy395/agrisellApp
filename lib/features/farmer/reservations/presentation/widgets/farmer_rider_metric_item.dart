import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/reservations/presentation/styles/farmer_rider_candidate_card_styles.dart';

class FarmerRiderMetricItem extends StatelessWidget {
  const FarmerRiderMetricItem({
    required this.icon,
    required this.label,
    super.key,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 1),
        child: Icon(
          icon,
          size: FarmerRiderCandidateCardStyles.metricIconSize,
          color: FarmerRiderCandidateCardStyles.metricIconColor,
        ),
      ),
      const SizedBox(width: 4),
      Flexible(
        child: Text(
          label,
          softWrap: true,
          style: FarmerRiderCandidateCardStyles.metricLabelStyle,
        ),
      ),
    ],
  );
}
