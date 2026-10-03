import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/reviews/domain/farmer_review_models.dart';
import 'package:agresell_app/features/shared/widgets/ratings/rating_stars.dart';

import '../styles/farmer_review_notice_styles.dart';
import '../styles/farmer_reviews_styles.dart';
import 'farmer_review_notice.dart';

class FarmerRatingsOverviewCard extends StatelessWidget {
  const FarmerRatingsOverviewCard({required this.summary, super.key});

  final FarmerRatingsSummary summary;

  @override
  Widget build(BuildContext context) {
    final distribution = [
      (
        stars: '5',
        percentage: summary.fiveStarPercent,
        count: summary.fiveStarCount,
      ),
      (
        stars: '4',
        percentage: summary.fourStarPercent,
        count: summary.fourStarCount,
      ),
      (
        stars: '3',
        percentage: summary.threeStarPercent,
        count: summary.threeStarCount,
      ),
      (
        stars: '2',
        percentage: summary.twoStarPercent,
        count: summary.twoStarCount,
      ),
      (
        stars: '1',
        percentage: summary.oneStarPercent,
        count: summary.oneStarCount,
      ),
    ];

    return Container(
      padding: FarmerReviewsStyles.overviewPadding,
      decoration: FarmerReviewsStyles.overviewDecoration,
      child: Column(
        crossAxisAlignment: FarmerReviewsStyles.alignStart,
        children: [
          Row(
            crossAxisAlignment: FarmerReviewsStyles.alignStart,
            children: [
              Column(
                crossAxisAlignment: FarmerReviewsStyles.alignStart,
                children: [
                  Text(
                    summary.averageRating.toStringAsFixed(1),
                    style: FarmerReviewsStyles.score,
                  ),
                  const SizedBox(height: FarmerReviewsStyles.smallGap),
                  RatingStars(
                    rating: summary.averageRating,
                    style: FarmerReviewsStyles.overviewStars,
                  ),
                  const SizedBox(height: FarmerReviewsStyles.labelGap),
                  Text(
                    '${summary.totalReviews} ${summary.totalReviews == 1 ? 'review' : 'reviews'}',
                    style: FarmerReviewsStyles.reviewCount,
                  ),
                ],
              ),
              const SizedBox(width: FarmerReviewsStyles.overviewColumnGap),
              Expanded(
                child: Column(
                  children: [
                    for (
                      var index = 0;
                      index < distribution.length;
                      index++
                    ) ...[
                      _StarDistributionRow(
                        starLabel: distribution[index].stars,
                        percentage: distribution[index].percentage,
                        count: distribution[index].count,
                      ),
                      if (index < distribution.length - 1)
                        const SizedBox(height: FarmerReviewsStyles.smallGap),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (summary.moderatedCount > 0) ...[
            const SizedBox(height: FarmerReviewsStyles.noticeGap),
            FarmerReviewNotice(
              title:
                  '${summary.moderatedCount} ${summary.moderatedCount == 1 ? 'review has' : 'reviews have'} admin moderation notes',
              icon: Icons.admin_panel_settings_outlined,
              style: FarmerReviewNoticeStyles.overview,
              expandTitle: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _StarDistributionRow extends StatelessWidget {
  const _StarDistributionRow({
    required this.starLabel,
    required this.percentage,
    required this.count,
  });

  final String starLabel;
  final double percentage;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: FarmerReviewsStyles.distributionLabelWidth,
          child: Row(
            mainAxisSize: FarmerReviewsStyles.shrinkWrap,
            children: [
              Text(starLabel, style: FarmerReviewsStyles.label),
              const SizedBox(width: FarmerReviewsStyles.tinyGap),
              const Icon(
                Icons.star_rounded,
                size: FarmerReviewsStyles.smallIconSize,
                color: FarmerReviewsStyles.starColor,
              ),
            ],
          ),
        ),
        const SizedBox(width: FarmerReviewsStyles.labelGap),
        Expanded(
          child: ClipRRect(
            borderRadius: FarmerReviewsStyles.progressRadius,
            child: LinearProgressIndicator(
              value: percentage / 100.0,
              minHeight: FarmerReviewsStyles.distributionHeight,
              backgroundColor: FarmerReviewsStyles.progressBackground,
              valueColor: FarmerReviewsStyles.progressColor,
            ),
          ),
        ),
        const SizedBox(width: FarmerReviewsStyles.inlineGap),
        SizedBox(
          width: FarmerReviewsStyles.distributionLabelWidth,
          child: Text(
            '$count',
            textAlign: FarmerReviewsStyles.trailingText,
            style: FarmerReviewsStyles.mutedLabel,
          ),
        ),
      ],
    );
  }
}
