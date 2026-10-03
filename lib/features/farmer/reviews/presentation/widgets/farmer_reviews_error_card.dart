import 'package:flutter/material.dart';

import '../styles/farmer_reviews_screen_styles.dart';

class FarmerReviewsErrorCard extends StatelessWidget {
  const FarmerReviewsErrorCard({
    required this.errorMessage,
    required this.onRetry,
    super.key,
  });

  final String errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
    padding: FarmerReviewsScreenStyles.errorCardPadding,
    decoration: FarmerReviewsScreenStyles.errorCardDecoration,
    child: Column(
      children: [
        const Icon(
          Icons.error_outline_rounded,
          color: FarmerReviewsScreenStyles.errorIconColor,
          size: FarmerReviewsScreenStyles.errorIconSize,
        ),
        const SizedBox(height: 10),
        Text(
          errorMessage,
          textAlign: TextAlign.center,
          style: FarmerReviewsScreenStyles.errorTextStyle,
        ),
        const SizedBox(height: 14),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Try Again'),
          style: FarmerReviewsScreenStyles.tryAgainButtonStyle,
        ),
      ],
    ),
  );
}
