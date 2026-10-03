import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

/// Predefined style tokens and variants for the SupportCenterScreen.
abstract final class SupportCenterStyles {
  // Screen
  static const screenBackground = AgrisellColors.homeBackground;
  static const indicatorColor = AgrisellColors.forestGreen;

  // AppBar
  static const appBarTitleStyle = TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: 15,
  );
  static const appBarBackground = AgrisellColors.surface;
  static const appBarForeground = AgrisellColors.headingGreen;

  // FloatingActionButton
  static const fabBackground = AgrisellColors.forestGreen;
  static const fabForeground = Colors.white;
  static const fabTextStyle = TextStyle(fontWeight: FontWeight.w700);

  // Search & Filter Header
  static const headerColor = AgrisellColors.surface;
  static const headerPadding = EdgeInsets.fromLTRB(16, 8, 16, 12);
  static final searchBorderRadius = BorderRadius.circular(12);
  static const searchContentPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 10,
  );
  static const searchHintStyle = TextStyle(
    fontSize: 13,
    color: AgrisellColors.mutedText,
  );

  // Filter Chips
  static final chipRadius = BorderRadius.circular(8);
  static const chipSelectedBackground = AgrisellColors.forestGreen;
  static const chipBackground = AgrisellColors.searchBackground;

  static TextStyle chipTextStyle({required bool isSelected}) => TextStyle(
    fontSize: 12,
    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
    color: isSelected ? Colors.white : AgrisellColors.headingGreen,
  );

  static BorderSide chipBorderSide({required bool isSelected}) => BorderSide(
    color: isSelected ? AgrisellColors.forestGreen : AgrisellColors.borderLine,
  );

  // Error State
  static const errorPadding = EdgeInsets.all(24);
  static const errorIconColor = AgrisellColors.unavailableRed;
  static const errorIconSize = 48.0;
  static const errorTextStyle = TextStyle(
    fontSize: 14,
    color: AgrisellColors.mutedText,
  );

  // Empty State
  static const emptyPadding = EdgeInsets.all(32);
  static const emptyBadgeSize = 72.0;
  static const emptyIconSize = 38.0;
  static const emptyIconColor = AgrisellColors.forestGreen;
  static final emptyBadgeDecoration = BoxDecoration(
    color: AgrisellColors.forestSoft,
    shape: BoxShape.circle,
  );
  static const emptyTitleStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.headingGreen,
  );
  static const emptySubtitleStyle = TextStyle(
    fontSize: 13,
    color: AgrisellColors.mutedText,
    height: 1.4,
  );
  static final openFirstTicketButtonStyle = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.forestGreen,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  // List layout
  static const listPadding = EdgeInsets.only(top: 8, bottom: 88);
}
