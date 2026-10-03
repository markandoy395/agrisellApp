import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class HomeHeaderStyles {
  static const handleWidth = 38.0;
  static const handleHeight = 4.0;
  static const tileLeadingSize = 38.0;
  static const tileIconSize = 20.0;
  static const chevronSize = 20.0;

  static EdgeInsets headerPadding(double horizontalPadding) =>
      EdgeInsets.fromLTRB(horizontalPadding, 14, horizontalPadding, 12);

  static const sheetMargin = EdgeInsets.all(12);
  static const sheetPadding = EdgeInsets.fromLTRB(10, 10, 10, 14);
  static final sheetBorderRadius = BorderRadius.circular(20);

  static final handleDecoration = BoxDecoration(
    color: AgrisellColors.mutedText.withValues(alpha: 0.35),
    borderRadius: BorderRadius.circular(4),
  );

  static const quickAccessTitleStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static final tileShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  );

  static const tileLeadingDecoration = BoxDecoration(
    color: AgrisellColors.forestSoft,
    shape: BoxShape.circle,
  );

  static const tileTitleStyle = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  static const tileSubtitleStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
  );
}
