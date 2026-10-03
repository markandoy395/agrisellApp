import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

/// Predefined style constants and decorations for the home search bar.
abstract final class HomeSearchBarStyles {
  // Dimensions
  static const double searchBarHeight = 48.0;
  static const double searchIconSize = 22.0;
  static const double filterIconSize = 22.0;
  static const double clearIconSize = 19.0;
  static const double filterButtonSize = 42.0;
  static const double badgeRadius = 8.0;

  // Insets
  static const EdgeInsets contentPadding = EdgeInsets.symmetric(vertical: 12);
  static final BorderRadius searchBorderRadius = BorderRadius.circular(24);
  static final BorderRadius filterBorderRadius = BorderRadius.circular(16);

  // Container Decoration
  static final BoxDecoration searchBarDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: searchBorderRadius,
    border: Border.all(
      color: AgrisellColors.authGreen.withValues(alpha: 0.12),
    ),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.12),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );

  // Typography
  static const TextStyle searchText = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle hintText = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle badgeText = TextStyle(
    color: AgrisellColors.surface,
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w800,
  );
}
