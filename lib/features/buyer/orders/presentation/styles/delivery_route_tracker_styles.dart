import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class DeliveryRouteTrackerStyles {
  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(
      color: AgrisellColors.authGreen.withValues(alpha: 0.15),
    ),
  );

  static final gpsCircleDecoration = BoxDecoration(
    color: AgrisellColors.authGreen.withValues(alpha: 0.12),
    shape: BoxShape.circle,
  );

  static const gpsStatusTitleStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.brandBlack,
  );

  static const gpsStatusSubtitleStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AgrisellColors.mutedText,
  );

  static final liveMapBadgeDecoration = BoxDecoration(
    color: AgrisellColors.authGreen,
    borderRadius: BorderRadius.circular(6),
  );

  static const liveMapTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );

  static BoxDecoration routeLineDecoration(Color color) => BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(999),
  );

  static BoxDecoration routeStopDecoration({
    required bool isActive,
    required Color color,
  }) => BoxDecoration(
    color: isActive ? color : AgrisellColors.surface,
    shape: BoxShape.circle,
    border: Border.all(
      color: isActive ? color : AgrisellColors.deliveryGray,
      width: 2,
    ),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.07),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
