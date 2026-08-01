import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/shared/products/domain/product_review.dart';
import 'package:agresell_app/features/shared/widgets/ratings/rating_stars.dart';

class ProductDetailReviewTile extends StatelessWidget {
  const ProductDetailReviewTile({required this.review, super.key});

  final ProductReview review;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const CircleAvatar(
            radius: 13,
            backgroundColor: AgrisellColors.forestSoft,
            child: Icon(
              Icons.person_outline_rounded,
              size: 16,
              color: AgrisellColors.authGreen,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              review.reviewerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AgrisellColors.brandBlack,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (review.submittedAt case final submittedAt?)
            Text(
              _dateLabel(submittedAt),
              style: const TextStyle(
                color: AgrisellColors.mutedText,
                fontSize: 12,
              ),
            ),
        ],
      ),
      const SizedBox(height: 6),
      RatingStars(
        rating: review.rating,
        precision: RatingStarPrecision.whole,
        style: const RatingStarsStyle(
          size: 18,
          filledColor: AgrisellColors.accentOrange,
          emptyColor: AgrisellColors.accentOrange,
        ),
      ),
      if (review.comment.isNotEmpty) ...[
        const SizedBox(height: 5),
        Text(
          review.comment,
          style: const TextStyle(
            color: AgrisellColors.brandBlack,
            fontSize: 13,
            height: 1.3,
          ),
        ),
      ],
    ],
  );

  String _dateLabel(DateTime date) {
    final local = date.toLocal();
    return '${local.month}/${local.day}/${local.year}';
  }
}
