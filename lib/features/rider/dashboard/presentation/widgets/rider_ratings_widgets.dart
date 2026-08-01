import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisellColors.dart';
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
              style: const TextStyle(
                color: AgrisellColors.headingGreen,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
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
                style: const TextStyle(
                  color: AgrisellColors.mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
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
                      style: const TextStyle(
                        color: AgrisellColors.headingGreen,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
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
                style: const TextStyle(
                  color: AgrisellColors.mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (review.comment?.trim().isNotEmpty ?? false) ...[
                const SizedBox(height: 9),
                Text(
                  review.comment!.trim(),
                  style: const TextStyle(
                    color: AgrisellColors.headingGreen,
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
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
