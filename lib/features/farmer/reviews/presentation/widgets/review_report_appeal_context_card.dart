import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/reviews/domain/farmer_review_models.dart';
import 'package:agresell_app/features/shared/widgets/ratings/rating_stars.dart';
import '../styles/review_report_appeal_styles.dart';

class ReviewReportAppealContextCard extends StatelessWidget {
  const ReviewReportAppealContextCard({
    required this.review,
    super.key,
  });

  final FarmerReview review;

  @override
  Widget build(BuildContext context) {
    final comment = review.comment?.trim();
    final hasComment = comment != null && comment.isNotEmpty;

    return Container(
      padding: ReviewReportAppealStyles.contextPadding,
      decoration: ReviewReportAppealStyles.contextCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.commodityName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ReviewReportAppealStyles.contextCommodity,
                ),
              ),
              RatingStars(
                rating: review.rating,
                style: ReviewReportAppealStyles.ratingStars,
              ),
            ],
          ),
          const SizedBox(height: ReviewReportAppealStyles.metaGap),
          Text(
            'By ${review.buyerName} • ${review.clientOrderId}',
            style: ReviewReportAppealStyles.contextMeta,
          ),
          if (hasComment) ...[
            const SizedBox(height: ReviewReportAppealStyles.commentGap),
            Text(
              '"$comment"',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: ReviewReportAppealStyles.contextComment,
            ),
          ],
        ],
      ),
    );
  }
}
