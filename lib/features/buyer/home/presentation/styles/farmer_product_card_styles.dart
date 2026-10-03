import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

/// Predefined style constants and metrics for the farmer product card.
abstract final class FarmerProductCardStyles {
  // Dimensions & Insets
  static const double cardHeight = 208.0;
  static const double detailsHeight = 90.0;
  static final BorderRadius cardBorderRadius = BorderRadius.circular(10);
  static const EdgeInsets detailsPadding = EdgeInsets.fromLTRB(10, 7, 10, 8);
  static const double metaIconSize = 14.0;
  static const double metaSpacing = 5.0;

  // Card Decoration
  static final BoxDecoration cardDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: cardBorderRadius,
    border: Border.all(color: AgrisellColors.borderLine),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.05),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Typography
  static const TextStyle nameText = TextStyle(
    fontSize: 14,
    height: 1.1,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle priceText = TextStyle(
    fontSize: 15,
    height: 1,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle unitText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle metaText = TextStyle(
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle harvestDateText = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w500,
  );
}
