import 'package:agresell_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

/// Predefined style constants for the rider delivery confirmation screen and form.
abstract final class RiderDeliveryConfirmationStyles {
  static const footerPadding = EdgeInsets.fromLTRB(14, 8, 14, 12);
  static final submitButton = FilledButton.styleFrom(
    minimumSize: const Size(double.infinity, 48),
    maximumSize: Size.infinite,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  );
  // Screen Styles
  static const Color background = AgrisellColors.homeBackground;
  static const Color closeIconColor = AgrisellColors.surface;

  static const listPadding = EdgeInsets.fromLTRB(14, 14, 14, 28);

  // Text Styles
  static const TextStyle requiredProofTitle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle bulletText = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 12,
  );

  static const TextStyle recipientLabel = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 12,
  );

  static const TextStyle recipientValue = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle recipientHelper = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 12,
  );

  static const TextStyle buyerConfirmationTitle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle gpsText = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  // Paddings & Insets
  static const EdgeInsets bulletPadding = EdgeInsets.only(top: 3);
  static const EdgeInsets checkboxPadding = EdgeInsets.zero;

  // Dimensions & Spacings
  static const double submitButtonHeight = 38.0;
  static const double iconSize18 = 18.0;
  static const double iconSize20 = 20.0;
  static const double spacing6 = 6.0;
  static const double spacing8 = 8.0;
  static const double spacing10 = 10.0;
  static const double spacing12 = 12.0;
  static const double spacing14 = 14.0;
}
