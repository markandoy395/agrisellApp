import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/reviews/domain/farmer_review_models.dart';
import 'package:agresell_app/features/shared/widgets/ratings/rating_stars.dart';

import '../styles/farmer_reviews_styles.dart';
import '../utils/review_date_formatter.dart';

class FarmerReviewHeader extends StatelessWidget {
  const FarmerReviewHeader({required this.review, super.key});

  final FarmerReview review;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: FarmerReviewsStyles.avatarRadius,
          backgroundColor: FarmerReviewsStyles.avatarBackground,
          child: Text(
            review.buyerName.isNotEmpty
                ? review.buyerName[0].toUpperCase()
                : 'B',
            style: FarmerReviewsStyles.avatar,
          ),
        ),
        const SizedBox(width: FarmerReviewsStyles.contentGap),
        Expanded(
          child: Column(
            crossAxisAlignment: FarmerReviewsStyles.alignStart,
            children: [
              Text(review.buyerName, style: FarmerReviewsStyles.buyerName),
              Text(
                formatFarmerReviewDate(review.createdAt),
                style: FarmerReviewsStyles.date,
              ),
            ],
          ),
        ),
        RatingStars(
          rating: review.rating,
          style: FarmerReviewsStyles.reviewStars,
        ),
      ],
    );
  }
}

class FarmerReviewProductBadge extends StatelessWidget {
  const FarmerReviewProductBadge({required this.review, super.key});

  final FarmerReview review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: FarmerReviewsStyles.productPadding,
      decoration: FarmerReviewsStyles.productDecoration,
      child: Row(
        mainAxisSize: FarmerReviewsStyles.shrinkWrap,
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: FarmerReviewsStyles.productIconSize,
            color: AgrisellColors.authGreen,
          ),
          const SizedBox(width: FarmerReviewsStyles.labelGap),
          Flexible(
            child: Text(
              review.commodityName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FarmerReviewsStyles.label,
            ),
          ),
          const SizedBox(width: FarmerReviewsStyles.inlineGap),
          Text(
            '• ${review.clientOrderId}',
            style: FarmerReviewsStyles.mutedLabel,
          ),
        ],
      ),
    );
  }
}
