import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

/// Predefined style constants and decorations for farmer product details.
abstract final class FarmerProductDetailsStyles {
  // Insets & Spacing
  static const EdgeInsets detailsPadding = EdgeInsets.fromLTRB(10, 8, 8, 8);
  static const EdgeInsets saleBadgePadding = EdgeInsets.symmetric(
    horizontal: 5,
    vertical: 2,
  );
  static const double iconSize = 14.0;
  static const double actionButtonDimension = 30.0;
  static const double actionIconSize = 18.0;
  static const double editIconSize = 16.0;

  // Sale Badge Decoration
  static final BoxDecoration saleBadgeDecoration = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(4),
    border: Border.all(
      color: AgrisellColors.authGreen.withValues(alpha: 0.3),
    ),
  );

  // Edit Button Decoration
  static final BoxDecoration editButtonDecoration = BoxDecoration(
    color: AgrisellColors.surface.withValues(alpha: 0.94),
    borderRadius: BorderRadius.circular(7),
    border: Border.all(color: AgrisellColors.borderLine),
  );

  // Typography
  static const TextStyle nameText = TextStyle(
    fontSize: 15,
    height: 1.1,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle priceText = TextStyle(
    fontSize: 15,
    height: 1,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle unitText = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle saleBadgeText = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle stockText = TextStyle(
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle dateText = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w500,
  );
}
