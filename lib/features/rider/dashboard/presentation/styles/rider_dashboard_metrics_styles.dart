import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderDashboardMetricsStyles {
  // Tile styles
  static const tilePadding = EdgeInsets.all(14);
  static const tileSize = 38.0;
  static const tileIconSize = 20.0;
  static final tileRadius = BorderRadius.circular(12);

  static const tileValueStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    height: 1,
    fontWeight: FontWeight.w900,
  );

  static const tileLabelStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.1,
    fontWeight: FontWeight.w700,
  );

  // Earnings card styles
  static const earningsPadding = EdgeInsets.all(16);
  static const earningsIconBoxSize = 46.0;
  static final earningsIconBoxRadius = BorderRadius.circular(14);
  static const earningsIconColor = AgrisellColors.authGreen;
  static const earningsIconSize = 24.0;
  static const earningsBoxColor = AgrisellColors.limeSoft;

  static const earningsValueStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    height: 1.1,
    fontWeight: FontWeight.w900,
  );

  static const earningsSubtitleStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.25,
    fontWeight: FontWeight.w600,
  );

  // Count action button
  static final countActionButtonStyle = OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
  );

  static const countActionIconSize = 17.0;

  // Grid spacings
  static const gridItemSpacing = 10.0;
  static const verticalGap = SizedBox(height: 10);
  static const horizontalGap = SizedBox(width: 10);
}
