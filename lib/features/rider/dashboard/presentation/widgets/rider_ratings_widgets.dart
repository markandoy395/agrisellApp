import 'package:flutter/material.dart'; 
import 'package:agresell_app/core/theme/agrisellColors.dart'; import 'package:agresell_app/features/rider/dashboard/domain/rider_rating_models.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_analytics_formatters.dart'; import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';
 class RiderRatingsOverview extends StatelessWidget {
  const RiderRatingsOverview({required this.summary, super.key}); 
  final RiderRatingsSummary summary; 
  @override Widget build(BuildContext context) => RiderSurfaceCard(
    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
      children: [ const RiderSectionTitle(title: 'Rider rating'),
        const SizedBox(height: 12), Row(
          children: [ Text(
              summary.averageRating.toStringAsFixed(1), style: const TextStyle(
                color: AgrisellColors.headingGreen, fontSize: 15,
                fontWeight: FontWeight.w800, ),
            ), const SizedBox(width: 6),
            RiderRatingStars(rating: summary.averageRating), const SizedBox(width: 8),
            Expanded( child: Text(
                '${summary.totalRatings} ratings', textAlign: TextAlign.end,
                style: const TextStyle( color: AgrisellColors.mutedText,
                  fontSize: 12, fontWeight: FontWeight.w600,
                ), ),
            ), ],
        ), const SizedBox(height: 14),
        Wrap( spacing: 14,
          runSpacing: 12, children: [
            _RatingMetric( label: 'Completed',
              value: '${summary.completedDeliveries}', ),
            _RatingMetric( label: 'Acceptance',
              value: '${summary.acceptanceRate.toStringAsFixed(1)}%', ),
            _RatingMetric( label: 'Completion',
              value: '${summary.completionRate.toStringAsFixed(1)}%', ),
            _RatingMetric( label: 'Cancellation',
              value: '${summary.cancellationRate.toStringAsFixed(1)}%', ),
            _RatingMetric( label: 'Pickup on time',
              value: '${summary.onTimePickupRate.toStringAsFixed(1)}%', ),
            _RatingMetric( label: 'Delivery on time',
              value: '${summary.onTimeDeliveryRate.toStringAsFixed(1)}%', ),
            _RatingMetric( label: 'Average wait',
              value: '${summary.averageWaitingMinutes.toStringAsFixed(1)} min', ),
            _RatingMetric( label: 'Failed delivery',
              value: '${summary.failedDeliveryRate.toStringAsFixed(1)}%', ),
          ], ),
      ], ),
  ); }
 class RiderReviewList extends StatelessWidget {
  const RiderReviewList({required this.reviews, super.key}); 
  final List<RiderReview> reviews; 
  @override Widget build(BuildContext context) => Column(
    children: [ const RiderSectionTitle(title: 'Customer reviews'),
      const SizedBox(height: 8), for (final review in reviews) ...[
        RiderSurfaceCard( child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row( children: [
                  Expanded( child: Text(
                      review.reviewerDisplayName ?? review.reviewerRole.label, style: const TextStyle(
                        color: AgrisellColors.headingGreen, fontSize: 13,
                        fontWeight: FontWeight.w800, ),
                    ), ),
                  RiderRatingStars(rating: review.rating), ],
              ), const SizedBox(height: 5),
              Text( '${review.reviewerRole.label} Â· ${formatRiderDate(review.createdAt)}',
                style: const TextStyle( color: AgrisellColors.mutedText,
                  fontSize: 12, fontWeight: FontWeight.w600,
                ), ),
              if (review.comment?.trim().isNotEmpty ?? false) ...[ const SizedBox(height: 9),
                Text( review.comment!.trim(),
                  style: const TextStyle( color: AgrisellColors.headingGreen,
                    fontSize: 12, height: 1.35,
                    fontWeight: FontWeight.w500, ),
                ), ],
            ], ),
        ), const SizedBox(height: 8),
      ], ],
  ); }
 class RiderRatingStars extends StatelessWidget {
  const RiderRatingStars({required this.rating, super.key}); 
  final double rating; 
  @override Widget build(BuildContext context) => Semantics(
    label: '${rating.toStringAsFixed(1)} out of 5 stars', child: ExcludeSemantics(
      child: Row( mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) { final amount = rating - index;
          return Icon( amount >= 1
                ? Icons.star_rounded : amount >= 0.5
                ? Icons.star_half_rounded : Icons.star_border_rounded,
            size: 16, color: AgrisellColors.accentOrange,
          ); }),
      ), ),
  ); }
 class _RatingMetric extends StatelessWidget {
  const _RatingMetric({required this.label, required this.value}); 
  final String label; final String value;
 @override
  Widget build(BuildContext context) => SizedBox( width: 90,
    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
      children: [ Text(
          value, style: const TextStyle(
            color: AgrisellColors.headingGreen, fontSize: 13,
            fontWeight: FontWeight.w800, ),
        ), Text(
          label, style: const TextStyle(
            color: AgrisellColors.mutedText, fontSize: 12,
            fontWeight: FontWeight.w600, ),
        ), ],
    ), );
}
