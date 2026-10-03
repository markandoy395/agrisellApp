import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/buyer/home/presentation/styles/farmer_card_details_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/home/domain/farmer_profile.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer/farmer_rating_line.dart';

class FarmerIdentity extends StatelessWidget {
  const FarmerIdentity({required this.farmer, super.key});

  final FarmerProfile farmer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          farmer.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: SharedPresentationStyles.headingTitleExtraBold,
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 15,
              color: AgrisellColors.mutedText,
            ),
            const SizedBox(width: 3),
            Expanded(
              child: Text(
                farmer.location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SharedPresentationStyles.mutedCaptionMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            FarmerRatingLine(rating: farmer.rating, starSize: 13),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                '${farmer.followerCount} followers',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SharedPresentationStyles.mutedCaptionMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class FarmerAvailabilityBadge extends StatelessWidget {
  const FarmerAvailabilityBadge({required this.availableProducts, super.key});

  final int availableProducts;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: FarmerCardDetailsStyles.containerDecoration,
      child: Column(
        children: [
          Text(
            '$availableProducts',
            style: SharedPresentationStyles.greenBodyExtraBold,
          ),
          const Text('available', style: FarmerCardDetailsStyles.availableText),
        ],
      ),
    );
  }
}
