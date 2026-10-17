import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../styles/farmer_reviews_screen_styles.dart';

class FarmerReviewsHeader extends StatelessWidget {
  const FarmerReviewsHeader({
    required this.onBack,
    required this.onRefresh,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) => Container(
    decoration: FarmerReviewsScreenStyles.headerDecoration,
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: FarmerReviewsScreenStyles.headerPadding,
        child: Row(
          children: [
            IconButton(
              tooltip: 'Back',
              onPressed: onBack,
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AgrisellColors.surface,
                size: 24,
              ),
            ),
            const SizedBox(width: 4),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reviews & Ratings',
                    style: FarmerReviewsScreenStyles.headerTitleStyle,
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Buyer feedback & admin moderation',
                    style: FarmerReviewsScreenStyles.headerSubtitleStyle,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Refresh',
              onPressed: onRefresh,
              icon: const Icon(
                Icons.refresh_rounded,
                color: AgrisellColors.surface,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
