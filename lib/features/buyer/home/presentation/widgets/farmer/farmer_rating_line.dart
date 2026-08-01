import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/shared/widgets/ratings/rating_stars.dart';

class FarmerRatingLine extends StatelessWidget {
  const FarmerRatingLine({required this.rating, this.starSize, super.key});

  final double rating;
  final double? starSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedStarSize =
            starSize ?? (constraints.maxWidth < 118 ? 18.0 : 22.0);

        return Wrap(
          spacing: 8,
          runSpacing: 2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            RatingStars(
              rating: rating,
              style: RatingStarsStyle(
                size: resolvedStarSize,
                filledColor: AgrisellColors.accentOrange,
                emptyColor: AgrisellColors.brandBlack,
                emptyIcon: Icons.star_rounded,
              ),
            ),
          ],
        );
      },
    );
  }
}
