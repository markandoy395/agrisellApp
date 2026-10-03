import 'package:flutter/material.dart';

import '../styles/farmer_reviews_styles.dart';

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
      padding: FarmerReviewsStyles.emptyPadding,
      alignment: FarmerReviewsStyles.center,
      decoration: FarmerReviewsStyles.emptyDecoration,
      child: Column(
        mainAxisSize: FarmerReviewsStyles.shrinkWrap,
        children: [
          const Icon(
            Icons.rate_review_outlined,
            size: FarmerReviewsStyles.emptyIconSize,
            color: FarmerReviewsStyles.emptyIconColor,
          ),
          const SizedBox(height: FarmerReviewsStyles.sectionGap),
          Text(title, style: FarmerReviewsStyles.emptyTitle),
          const SizedBox(height: FarmerReviewsStyles.labelGap),
          Text(
            message,
            textAlign: FarmerReviewsStyles.centeredText,
            style: FarmerReviewsStyles.emptyMessage,
          ),
        ],
      ),
    );
  }
}
