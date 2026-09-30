import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/reviews/domain/farmer_review_models.dart';
import 'package:agresell_app/features/farmer/reviews/presentation/controllers/farmer_reviews_controller.dart';
import 'package:agresell_app/features/shared/widgets/ratings/rating_stars.dart';

class FarmerRatingsOverviewCard extends StatelessWidget {
  const FarmerRatingsOverviewCard({required this.summary, super.key});

  final FarmerRatingsSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rating Score Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary.averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AgrisellColors.headingGreen,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RatingStars(
                    rating: summary.averageRating,
                    style: const RatingStarsStyle(
                      size: 18,
                      filledColor: AgrisellColors.accentOrange,
                      emptyColor: Color(0xFFD6DFDB),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${summary.totalReviews} ${summary.totalReviews == 1 ? 'review' : 'reviews'}',
                    style: const TextStyle(
                      color: AgrisellColors.mutedText,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              // Rating Distribution Bars
              Expanded(
                child: Column(
                  children: [
                    _StarDistributionRow(
                      starLabel: '5',
                      percentage: summary.fiveStarPercent,
                      count: summary.fiveStarCount,
                    ),
                    const SizedBox(height: 4),
                    _StarDistributionRow(
                      starLabel: '4',
                      percentage: summary.fourStarPercent,
                      count: summary.fourStarCount,
                    ),
                    const SizedBox(height: 4),
                    _StarDistributionRow(
                      starLabel: '3',
                      percentage: summary.threeStarPercent,
                      count: summary.threeStarCount,
                    ),
                    const SizedBox(height: 4),
                    _StarDistributionRow(
                      starLabel: '2',
                      percentage: summary.twoStarPercent,
                      count: summary.twoStarCount,
                    ),
                    const SizedBox(height: 4),
                    _StarDistributionRow(
                      starLabel: '1',
                      percentage: summary.oneStarPercent,
                      count: summary.oneStarCount,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (summary.moderatedCount > 0) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3FAF6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFCDE4D7)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.admin_panel_settings_outlined,
                    size: 18,
                    color: AgrisellColors.authGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${summary.moderatedCount} ${summary.moderatedCount == 1 ? 'review has' : 'reviews have'} admin moderation notes',
                      style: const TextStyle(
                        color: AgrisellColors.headingGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
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
          width: 28,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                starLabel,
                style: const TextStyle(
                  color: AgrisellColors.headingGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.star_rounded,
                size: 12,
                color: AgrisellColors.accentOrange,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100.0,
              minHeight: 6,
              backgroundColor: const Color(0xFFE5ECE8),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AgrisellColors.authGreen,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 28,
          child: Text(
            '$count',
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: AgrisellColors.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class FarmerReviewsFilterBar extends StatelessWidget {
  const FarmerReviewsFilterBar({
    required this.selectedFilter,
    required this.onFilterSelected,
    this.moderatedCount = 0,
    super.key,
  });

  final FarmerReviewsFilter selectedFilter;
  final ValueChanged<FarmerReviewsFilter> onFilterSelected;
  final int moderatedCount;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: FarmerReviewsFilter.values.map((filter) {
          final isSelected = filter == selectedFilter;
          final label = filter == FarmerReviewsFilter.withNotes && moderatedCount > 0
              ? 'With Notes ($moderatedCount)'
              : filter.label;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => onFilterSelected(filter),
              selectedColor: AgrisellColors.authGreen,
              backgroundColor: AgrisellColors.surface,
              labelStyle: TextStyle(
                color: isSelected ? AgrisellColors.surface : AgrisellColors.headingGreen,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected ? AgrisellColors.authGreen : const Color(0xFFD6DFDB),
                ),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class FarmerReviewCard extends StatelessWidget {
  const FarmerReviewCard({
    required this.review,
    this.onReportReview,
    this.onAppealModeration,
    super.key,
  });

  final FarmerReview review;
  final ValueChanged<FarmerReview>? onReportReview;
  final ValueChanged<FarmerReview>? onAppealModeration;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Buyer & Rating Header
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFE2EFE7),
                child: Text(
                  review.buyerName.isNotEmpty
                      ? review.buyerName[0].toUpperCase()
                      : 'B',
                  style: const TextStyle(
                    color: AgrisellColors.authGreen,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.buyerName,
                      style: const TextStyle(
                        color: AgrisellColors.headingGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      _formatDate(review.createdAt),
                      style: const TextStyle(
                        color: AgrisellColors.mutedText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              RatingStars(
                rating: review.rating,
                style: const RatingStarsStyle(
                  size: 16,
                  filledColor: AgrisellColors.accentOrange,
                  emptyColor: Color(0xFFD6DFDB),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Product & Order Reference Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F6F4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 14,
                  color: AgrisellColors.authGreen,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    review.commodityName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AgrisellColors.headingGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '• ${review.clientOrderId}',
                  style: const TextStyle(
                    color: AgrisellColors.mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Review Comment
          if (review.comment != null && review.comment!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment!.trim(),
              style: const TextStyle(
                color: AgrisellColors.headingGreen,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          // Admin Moderation Note
          if (review.hasAdminNote || review.isHidden || review.isFlagged) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: review.isHidden
                    ? const Color(0xFFFDF3F2)
                    : const Color(0xFFFDF8EE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: review.isHidden
                      ? const Color(0xFFF5C6CB)
                      : const Color(0xFFFCE1B5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        review.isHidden
                            ? Icons.visibility_off_outlined
                            : Icons.shield_outlined,
                        size: 16,
                        color: review.isHidden
                            ? const Color(0xFFB82828)
                            : const Color(0xFF9E6B08),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        review.isHidden
                            ? 'Admin Moderation: Hidden from Marketplace'
                            : 'Admin Moderation Note',
                        style: TextStyle(
                          color: review.isHidden
                              ? const Color(0xFFB82828)
                              : const Color(0xFF9E6B08),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  if (review.hasAdminNote) ...[
                    const SizedBox(height: 4),
                    Text(
                      review.adminModerationNote!,
                      style: const TextStyle(
                        color: Color(0xFF4A4031),
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Admin Response / Support Reply
          if (review.hasAdminResponse) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF5EE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFB8E0CA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.support_agent_rounded,
                        size: 16,
                        color: AgrisellColors.authGreen,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Agrisell Support Response',
                        style: TextStyle(
                          color: AgrisellColors.headingGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review.adminResponse!,
                    style: const TextStyle(
                      color: AgrisellColors.headingGreen,
                      fontSize: 12,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Report / Appeal Status or Action Buttons
          if (review.isReportOpen) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.pending_actions_rounded,
                    size: 16,
                    color: Color(0xFFB45309),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Report / Appeal Under Admin Review',
                      style: TextStyle(
                        color: Color(0xFF92400E),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (review.canAppeal) ...[
                  OutlinedButton.icon(
                    onPressed: () => onAppealModeration?.call(review),
                    icon: const Icon(
                      Icons.shield_outlined,
                      size: 14,
                      color: AgrisellColors.authGreen,
                    ),
                    label: const Text('Appeal Moderation'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AgrisellColors.authGreen,
                      side: const BorderSide(color: Color(0xFFCDE4D7)),
                      backgroundColor: const Color(0xFFF3FAF6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (review.canReport) ...[
                  OutlinedButton.icon(
                    onPressed: () => onReportReview?.call(review),
                    icon: const Icon(
                      Icons.flag_outlined,
                      size: 14,
                      color: Color(0xFFB82828),
                    ),
                    label: const Text('Report Review'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB82828),
                      side: const BorderSide(color: Color(0xFFF5C6CB)),
                      backgroundColor: const Color(0xFFFDF2F2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        final mins = difference.inMinutes;
        return mins <= 1 ? 'Just now' : '$mins mins ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}

class FarmerReviewsEmptyCard extends StatelessWidget {
  const FarmerReviewsEmptyCard({
    this.title = 'No reviews found',
    this.message = 'Customer reviews matching your criteria will appear here.',
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.rate_review_outlined,
            size: 48,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: AgrisellColors.headingGreen,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AgrisellColors.mutedText,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
