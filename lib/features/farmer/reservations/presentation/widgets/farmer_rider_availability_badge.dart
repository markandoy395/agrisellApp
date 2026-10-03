import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/reservations/presentation/styles/farmer_rider_candidate_card_styles.dart';

class FarmerRiderAvailabilityBadge extends StatelessWidget {
  const FarmerRiderAvailabilityBadge({required this.status, super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    final online = status == 'online';
    return Container(
      padding: FarmerRiderCandidateCardStyles.badgePadding,
      decoration: FarmerRiderCandidateCardStyles.badgeDecoration(online),
      child: Text(
        FarmerRiderCandidateCardStyles.availabilityLabel(status),
        style: FarmerRiderCandidateCardStyles.badgeTextStyle(online),
      ),
    );
  }
}
