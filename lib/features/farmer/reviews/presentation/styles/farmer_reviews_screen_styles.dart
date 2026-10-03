import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

/// Predefined style tokens and variants for the farmer reviews screen.
abstract final class FarmerReviewsScreenStyles {
  // Screen background
  static const screenBackground = AgrisellColors.homeBackground;

  // Header
  static const headerPadding = EdgeInsets.fromLTRB(16, 12, 16, 12);
  static const headerDecoration = BoxDecoration(
    color: AgrisellColors.authGreen,
    borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
  );
  static const headerTitleStyle = TextStyle(
    color: AgrisellColors.surface,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );
  static const headerSubtitleStyle = TextStyle(
    color: Color(0xFFD3EADE),
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // Search bar
  static const searchBarPadding = EdgeInsets.fromLTRB(16, 12, 16, 4);
  static final searchInputBorderRadius = BorderRadius.circular(14);
  static const searchBorderSide = BorderSide(color: Color(0xFFE2E9EC));
  static const searchFocusedBorderSide = BorderSide(
    color: AgrisellColors.authGreen,
    width: 1.5,
  );
  static const searchContentPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 10,
  );
  static const searchHintStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 13,
  );

  // Error card
  static const errorCardPadding = EdgeInsets.all(20);
  static final errorCardDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(16),
  );
  static const errorIconColor = Color(0xFFB82828);
  static const errorIconSize = 40.0;
  static const errorTextStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );
  static final tryAgainButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: AgrisellColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );

  // List layout
  static const listPadding = EdgeInsets.fromLTRB(16, 8, 16, 32);
  static const indicatorColor = AgrisellColors.authGreen;
}
