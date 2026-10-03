import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/buyer/home/presentation/styles/product_detail_review_tile_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
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
              style: SharedPresentationStyles.inkBodyExtraBold,
            ),
          ),
          if (review.submittedAt case final submittedAt?)
            Text(
              _dateLabel(submittedAt),
              style: SharedPresentationStyles.mutedCaption,
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
        Text(review.comment, style: ProductDetailReviewTileStyles.textStyle),
      ],
      if (review.moderationStatus != null ||
          (review.moderationNote != null &&
              review.moderationNote!.isNotEmpty)) ...[
        const SizedBox(height: 8),
        Container(
          key: const Key('review-moderation-banner'),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: ProductDetailReviewTileStyles.containerDecoration,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.shield_outlined,
                size: 15,
                color: AgrisellColors.statusBlueText,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (review.moderationStatus case final status?)
                      Text(
                        _moderationStatusLabel(status),
                        style: ProductDetailReviewTileStyles.textStyle2,
                      ),
                    if (review.moderationNote case final note?) ...[
                      if (review.moderationStatus != null)
                        const SizedBox(height: 2),
                      Text(note, style: ProductDetailReviewTileStyles.noteText),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
      if (review.adminResponse case final adminResponse?) ...[
        const SizedBox(height: 8),
        Container(
          key: const Key('review-admin-response-card'),
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: ProductDetailReviewTileStyles.containerDecoration2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 15,
                    color: AgrisellColors.authGreen,
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'Admin response',
                    style: SharedPresentationStyles.greenCaptionExtraBold,
                  ),
                  const Spacer(),
                  if (review.adminRespondedAt case final respondedAt?)
                    Text(
                      _dateLabel(respondedAt),
                      style: SharedPresentationStyles.mutedCaption,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                adminResponse,
                style: ProductDetailReviewTileStyles.textStyle,
              ),
            ],
          ),
        ),
      ],
    ],
  );

  String _moderationStatusLabel(String status) =>
      switch (status.toLowerCase()) {
        'resolved' => 'Moderation: Report resolved',
        'dismissed' => 'Moderation: Report dismissed',
        'open' => 'Moderation: Under review',
        _ => 'Moderated review',
      };

  String _dateLabel(DateTime date) {
    final local = date.toLocal();
    return '${local.month}/${local.day}/${local.year}';
  }
}
