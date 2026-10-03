import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/reviews/domain/farmer_review_models.dart';
import '../styles/farmer_reviews_styles.dart';
import '../styles/farmer_review_action_styles.dart';
import '../styles/farmer_review_notice_styles.dart';
import 'farmer_review_notice.dart';

class FarmerReviewActions extends StatelessWidget {
  const FarmerReviewActions({
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
    if (review.isReportOpen) {
      return FarmerReviewNotice(
        title: 'Report / Appeal Under Admin Review',
        icon: Icons.pending_actions_rounded,
        style: FarmerReviewNoticeStyles.pending,
        expandTitle: true,
      );
    }

    return Row(
      mainAxisAlignment: FarmerReviewsStyles.alignEnd,
      children: [
        if (review.canAppeal) ...[
          OutlinedButton.icon(
            onPressed: () => onAppealModeration?.call(review),
            icon: const Icon(
              Icons.shield_outlined,
              size: FarmerReviewActionStyles.iconSize,
              color: AgrisellColors.authGreen,
            ),
            label: const Text('Appeal Moderation'),
            style: FarmerReviewActionStyles.appealButton,
          ),
          const SizedBox(width: FarmerReviewsStyles.inlineGap),
        ],
        if (review.canReport)
          OutlinedButton.icon(
            onPressed: () => onReportReview?.call(review),
            icon: const Icon(
              Icons.flag_outlined,
              size: FarmerReviewActionStyles.iconSize,
              color: FarmerReviewActionStyles.reportColor,
            ),
            label: const Text('Report Review'),
            style: FarmerReviewActionStyles.reportButton,
          ),
      ],
    );
  }
}
