import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_candidate.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/styles/farmer_rider_candidate_card_styles.dart';
import 'package:agresell_app/features/shared/widgets/profile/safe_circle_avatar.dart';

class FarmerRiderAvatar extends StatelessWidget {
  const FarmerRiderAvatar({required this.rider, super.key});

  final FarmerRiderCandidate rider;

  @override
  Widget build(BuildContext context) {
    final initials = rider.name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return SafeCircleAvatar(
      radius: FarmerRiderCandidateCardStyles.avatarRadius,
      backgroundColor: FarmerRiderCandidateCardStyles.avatarBackground,
      imageUrl: rider.profileImageUrl,
      fallback: Text(
        initials.isEmpty ? 'R' : initials,
        style: FarmerRiderCandidateCardStyles.avatarFallbackStyle,
      ),
    );
  }
}
