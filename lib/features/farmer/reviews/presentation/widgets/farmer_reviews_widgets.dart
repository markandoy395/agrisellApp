import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/reviews/domain/farmer_review_models.dart';

import '../styles/farmer_review_notice_styles.dart';
import '../styles/farmer_reviews_styles.dart';
import 'farmer_review_actions.dart';
import 'farmer_review_metadata.dart';
import 'farmer_review_notice.dart';

export 'farmer_ratings_overview_card.dart' show FarmerRatingsOverviewCard;
export 'farmer_reviews_empty_card.dart' show FarmerReviewsEmptyCard;
export 'farmer_reviews_filter_bar.dart' show FarmerReviewsFilterBar;

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
    final comment = review.comment?.trim();

    return Container(
      margin: FarmerReviewsStyles.reviewMargin,
      padding: FarmerReviewsStyles.reviewPadding,
      decoration: FarmerReviewsStyles.reviewDecoration,
      child: Column(
        crossAxisAlignment: FarmerReviewsStyles.alignStart,
        children: [
          FarmerReviewHeader(review: review),
          const SizedBox(height: FarmerReviewsStyles.contentGap),
          FarmerReviewProductBadge(review: review),
          if (comment != null && comment.isNotEmpty) ...[
            const SizedBox(height: FarmerReviewsStyles.contentGap),
            Text(comment, style: FarmerReviewsStyles.comment),
          ],
          if (review.hasAdminNote || review.isHidden || review.isFlagged) ...[
            const SizedBox(height: FarmerReviewsStyles.sectionGap),
            FarmerReviewNotice(
              title: review.isHidden
                  ? 'Admin Moderation: Hidden from Marketplace'
                  : 'Admin Moderation Note',
              icon: review.isHidden
                  ? Icons.visibility_off_outlined
                  : Icons.shield_outlined,
              style: review.isHidden
                  ? FarmerReviewNoticeStyles.hidden
                  : FarmerReviewNoticeStyles.moderation,
              body: review.hasAdminNote ? review.adminModerationNote : null,
            ),
          ],
          if (review.hasAdminResponse) ...[
            const SizedBox(height: FarmerReviewsStyles.contentGap),
            FarmerReviewNotice(
              title: 'Agrisell Support Response',
              icon: Icons.support_agent_rounded,
              style: FarmerReviewNoticeStyles.support,
              body: review.adminResponse,
            ),
          ],
          const SizedBox(height: FarmerReviewsStyles.sectionGap),
          FarmerReviewActions(
            review: review,
            onReportReview: onReportReview,
            onAppealModeration: onAppealModeration,
          ),
        ],
      ),
    );
  }
}
