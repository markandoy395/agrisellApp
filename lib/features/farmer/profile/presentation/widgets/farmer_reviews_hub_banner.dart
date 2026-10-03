import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/farmer/profile/presentation/styles/farmer_history_screen_styles.dart';
import 'package:agresell_app/features/farmer/reviews/presentation/screens/farmer_reviews_screen.dart';

class FarmerReviewsHubBanner extends StatelessWidget {
  const FarmerReviewsHubBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: FarmerHistoryScreenStyles.reviewsBannerMargin,
      padding: FarmerHistoryScreenStyles.reviewsBannerPadding,
      decoration: FarmerHistoryScreenStyles.reviewsBannerDecoration,
      child: Row(
        children: [
          const Icon(
            Icons.star_rounded,
            color: FarmerHistoryScreenStyles.reviewsBannerIconColor,
            size: 28,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reviews & Ratings Hub',
                  style: FarmerHistoryScreenStyles.reviewsBannerTitleStyle,
                ),
                SizedBox(height: 2),
                Text(
                  'View star breakdown, buyer notes & moderation details',
                  style: FarmerHistoryScreenStyles.reviewsBannerSubtitleStyle,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.tonal(
            onPressed: () {
              Navigator.of(context).push(
                agrisellPageRoute<void>(
                  builder: (_) => const FarmerReviewsScreen(),
                ),
              );
            },
            style: FarmerHistoryScreenStyles.reviewsBannerButtonStyle,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Open Hub',
                  style:
                      FarmerHistoryScreenStyles.reviewsBannerButtonTextStyle,
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
