import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_ratings_widgets_styles.dart';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_rating_models.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_analytics_formatters.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';
import 'package:agresell_app/features/shared/widgets/metrics/summary_metric.dart';
import 'package:agresell_app/features/shared/widgets/ratings/rating_stars.dart';

class RiderRatingsOverview extends StatelessWidget {
  const RiderRatingsOverview({required this.summary, super.key});
  final RiderRatingsSummary summary;
  @override
  Widget build(BuildContext context) => RiderSurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RiderSectionTitle(title: 'Rider rating'),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              summary.averageRating.toStringAsFixed(1),
              style: SharedPresentationStyles.headingTitleExtraBold,
            ),
            const SizedBox(width: 6),
            RatingStars(
              rating: summary.averageRating,
              style: const RatingStarsStyle(
                size: 16,
                filledColor: AgrisellColors.accentOrange,
                emptyColor: AgrisellColors.accentOrange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${summary.totalRatings} ratings',
                textAlign: TextAlign.end,
                style: SharedPresentationStyles.mutedCaptionSemibold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 14,
          runSpacing: 12,
          children: [
            SummaryMetric(
              label: 'Completed',
              value: '${summary.completedDeliveries}',
            ),
            SummaryMetric(
              label: 'Acceptance',
              value: '${summary.acceptanceRate.toStringAsFixed(1)}%',
            ),
            SummaryMetric(
              label: 'Completion',
              value: '${summary.completionRate.toStringAsFixed(1)}%',
            ),
            SummaryMetric(
              label: 'Cancellation',
              value: '${summary.cancellationRate.toStringAsFixed(1)}%',
            ),
            SummaryMetric(
              label: 'Pickup on time',
              value: '${summary.onTimePickupRate.toStringAsFixed(1)}%',
            ),
            SummaryMetric(
              label: 'Delivery on time',
              value: '${summary.onTimeDeliveryRate.toStringAsFixed(1)}%',
            ),
            SummaryMetric(
              label: 'Average wait',
              value: '${summary.averageWaitingMinutes.toStringAsFixed(1)} min',
            ),
            SummaryMetric(
              label: 'Failed delivery',
              value: '${summary.failedDeliveryRate.toStringAsFixed(1)}%',
            ),
          ],
        ),
      ],
    ),
  );
}

class RiderReviewList extends StatelessWidget {
  const RiderReviewList({required this.reviews, super.key});
  final List<RiderReview> reviews;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      const RiderSectionTitle(title: 'Customer reviews'),
      const SizedBox(height: 8),
      for (final review in reviews) ...[
        RiderSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      review.reviewerDisplayName ?? review.reviewerRole.label,
                      style: SharedPresentationStyles.headingBodyExtraBold,
                    ),
                  ),
                  RatingStars(
                    rating: review.rating,
                    style: const RatingStarsStyle(
                      size: 16,
                      filledColor: AgrisellColors.accentOrange,
                      emptyColor: AgrisellColors.accentOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                '${review.reviewerRole.label} Â· ${formatRiderDate(review.createdAt)}',
                style: SharedPresentationStyles.mutedCaptionSemibold,
              ),
              if (review.comment?.trim().isNotEmpty ?? false) ...[
                const SizedBox(height: 9),
                Text(
                  review.comment!.trim(),
                  style: RiderRatingsWidgetsStyles.textStyle,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    ],
  );
}
