import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_candidate.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/styles/farmer_rider_candidate_card_styles.dart';

class FarmerRiderIdentitySection extends StatelessWidget {
  const FarmerRiderIdentitySection({required this.rider, super.key});

  final FarmerRiderCandidate rider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rider.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: FarmerRiderCandidateCardStyles.nameStyle,
        ),
        const SizedBox(height: 3),
        Text(
          '${rider.barangay}, ${rider.municipality}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: FarmerRiderCandidateCardStyles.locationStyle,
        ),
        if (rider.sameBarangay)
          const Padding(
            padding: FarmerRiderCandidateCardStyles.localityPadding,
            child: Text(
              'Same pickup barangay',
              style: FarmerRiderCandidateCardStyles.localityHighlightStyle,
            ),
          )
        else if (rider.sameMunicipality)
          const Padding(
            padding: FarmerRiderCandidateCardStyles.localityPadding,
            child: Text(
              'Suggested: same municipality',
              style: FarmerRiderCandidateCardStyles.localityHighlightStyle,
            ),
          ),
        if (!rider.locationIsFresh && rider.distanceKm == null)
          const Padding(
            padding: FarmerRiderCandidateCardStyles.localityPadding,
            child: Text(
              'Current GPS not available',
              style: FarmerRiderCandidateCardStyles.gpsWarningStyle,
            ),
          ),
      ],
    );
  }
}
