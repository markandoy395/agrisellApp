import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderActiveDeliverySummaryStyles {
  // Card paddings
  static const emptyCardPadding = EdgeInsets.all(18);
  static const activeCardPadding = EdgeInsets.all(16);

  // Empty state styles
  static const emptyTitleStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    fontWeight: FontWeight.w900,
  );
  static const emptySubtitleStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );
  static final iconBadgeRadius = BorderRadius.circular(14);
  static const iconBadgeSize = 48.0;
  static const iconBadgeIconSize = 24.0;
  static const emptyBadgeBackground = AgrisellColors.statusBlueBackground;
  static const emptyBadgeForeground = AgrisellColors.statusBlueText;

  // Active delivery header
  static const productNameStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    fontWeight: FontWeight.w900,
  );
  static const orderNumberStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );
  static final productImageRadius = BorderRadius.circular(14);
  static const productImageDimension = 62.0;

  // Next action box
  static const nextActionPadding = EdgeInsets.all(12);
  static final nextActionBoxDecoration = BoxDecoration(
    color: AgrisellColors.pageBackground,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AgrisellColors.borderLine),
  );
  static const nextActionTitleStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 12,
    height: 1.25,
    fontWeight: FontWeight.w800,
  );
  static const nextActionDeadlineStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.25,
    fontWeight: FontWeight.w600,
  );

  // Route stop styles
  static const routeStopBoxSize = 30.0;
  static final routeStopIconBoxDecoration = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(10),
  );
  static const routeStopIconColor = AgrisellColors.authGreen;
  static const routeStopIconSize = 17.0;
  static const routeStopLabelStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.1,
    fontWeight: FontWeight.w800,
  );
  static const routeStopValueStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 12,
    height: 1.25,
    fontWeight: FontWeight.w700,
  );

  // Spacings
  static const spacingIconBadge = SizedBox(width: 12);
  static const spacingTitleSubtitle = SizedBox(height: 4);
  static const spacingEmptyAction = SizedBox(height: 14);
  static const spacingImage = SizedBox(width: 12);
  static const spacingTitleOrder = SizedBox(width: 8);
  static const spacingTitlePills = SizedBox(height: 7);
  static const spacingSection = SizedBox(height: 14);
  static const spacingStops = SizedBox(height: 8);
  static const spacingNextAction = SizedBox(height: 12);
  static const spacingNextActionTexts = SizedBox(height: 4);
  static const spacingActions = SizedBox(width: 8);
  static const spacingRouteStopIcon = SizedBox(width: 10);
  static const spacingRouteStopTexts = SizedBox(height: 2);
  static const pillSpacing = 7.0;
}
