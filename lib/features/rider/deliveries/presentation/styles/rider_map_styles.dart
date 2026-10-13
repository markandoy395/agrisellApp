import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

/// Predefined style constants and variants for the rider map presentation.
abstract final class RiderMapStyles {
  // --- Layout Insets & Sizes ---
  static const topOverlayPadding = EdgeInsets.symmetric(horizontal: 12);
  static const fallbackPadding = EdgeInsets.all(14);
  static const toolbarPadding = EdgeInsets.only(left: 14, right: 4);
  static const errorPadding = EdgeInsets.fromLTRB(12, 7, 6, 7);
  static const activeCardPadding = EdgeInsets.fromLTRB(12, 8, 8, 8);

  static const overlaySpacing = 8.0;
  static const chipSpacing = 7.0;
  static const filterRowHeight = 39.0;
  static const controlsRight = 14.0;
  static const activeCardCompactBreakpoint = 430.0;
  static const routePanelBottom = 8.0;

  // --- Dimensions & Strokes ---
  static const spinnerDimension = 18.0;
  static const spinnerStrokeWidth = 2.0;
  static const actionIconSize = 17.0;
  static const chipIconSize = 17.0;
  static const avatarRadius = 18.0;
  static const avatarIconSize = 20.0;
  static const errorIconSize = 18.0;

  // --- Radii & Elevations ---
  static final toolbarRadius = BorderRadius.circular(16);
  static final errorRadius = BorderRadius.circular(12);
  static final activeCardRadius = BorderRadius.circular(14);

  static const toolbarElevation = 3.0;
  static const activeCardElevation = 4.0;
  static const filterChipElevation = 2.0;

  // --- Background Colors ---
  static final toolbarBackground = AgrisellColors.surface.withValues(
    alpha: 0.94,
  );
  static final errorBackground = AgrisellColors.statusOrangeBackground
      .withValues(alpha: 0.96);
  static final activeCardBackground = AgrisellColors.surface.withValues(
    alpha: 0.96,
  );
  static final chipBackground = AgrisellColors.surface.withValues(alpha: 0.94);
  static const fabBackground = AgrisellColors.surface;
  static const fabForeground = AgrisellColors.authGreen;

  // --- Typography & Text Styles ---
  static const toolbarTitle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontWeight: FontWeight.w800,
  );

  static const toolbarSubtitle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
  );

  static const errorText = TextStyle(
    color: AgrisellColors.statusOrangeText,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const chipLabel = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const activeCardBadge = TextStyle(
    color: AgrisellColors.statusOrangeText,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );

  static const activeCardProduct = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  // --- Conditional Style Variants ---
  static double controlsBottom({required bool navigationActive}) =>
      navigationActive ? 174.0 : 20.0;
}
