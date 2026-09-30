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
      if (review.moderationStatus != null ||
          (review.moderationNote != null &&
              review.moderationNote!.isNotEmpty)) ...[
        const SizedBox(height: 8),
        Container(
          key: const Key('review-moderation-banner'),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AgrisellColors.statusBlueBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AgrisellColors.accentBlue.withValues(alpha: 0.3),
            ),
          ),
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
                        style: const TextStyle(
                          color: AgrisellColors.statusBlueText,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    if (review.moderationNote case final note?) ...[
                      if (review.moderationStatus != null)
                        const SizedBox(height: 2),
                      Text(
                        note,
                        style: const TextStyle(
                          color: AgrisellColors.headingGreenAlt,
                          fontSize: 12,
                          height: 1.25,
                        ),
                      ),
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
          decoration: BoxDecoration(
            color: AgrisellColors.forestSoft.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(8),
            border: const Border(
              left: BorderSide(
                color: AgrisellColors.authGreen,
                width: 3.5,
              ),
            ),
          ),
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
                    style: TextStyle(
                      color: AgrisellColors.authGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  if (review.adminRespondedAt case final respondedAt?)
                    Text(
                      _dateLabel(respondedAt),
                      style: const TextStyle(
                        color: AgrisellColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                adminResponse,
                style: const TextStyle(
                  color: AgrisellColors.brandBlack,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    ],
  );

  String _moderationStatusLabel(String status) => switch (status.toLowerCase()) {
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
