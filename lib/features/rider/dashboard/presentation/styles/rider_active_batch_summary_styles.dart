import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderActiveBatchSummaryStyles {
  static const cardPadding = EdgeInsets.all(14);
  static const itemPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 8);
  static const itemMargin = EdgeInsets.only(bottom: 6);

  static final itemBorderRadius = BorderRadius.circular(10);

  static const headerTitleStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    fontWeight: FontWeight.w900,
  );

  static const detailValueStyle = TextStyle(
    color: AgrisellColors.headingGreenAlt,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const metricStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const itemTitleStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );

  static const itemSubtitleStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
  );

  static const headerIconColor = AgrisellColors.authGreen;
  static const headerIconSize = 20.0;
  static const detailIconColor = AgrisellColors.authGreen;
  static const detailIconSize = 18.0;
  static const itemIconColor = AgrisellColors.authGreen;
  static const itemIconSize = 18.0;
  static const itemTrailingIconColor = AgrisellColors.mutedText;

  static const spacingSmall = SizedBox(width: 8);
  static const spacingVertical = SizedBox(height: 10);
  static const wrapSpacing = 12.0;
  static const wrapRunSpacing = 6.0;
}
