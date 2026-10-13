import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

/// Predefined style constants for the rider delivery confirmation screen and form.
abstract final class RiderDeliveryConfirmationStyles {
  // Screen Styles
  static const Color background = AgrisellColors.homeBackground;
  static const Color closeIconColor = AgrisellColors.surface;

  static const listPadding = EdgeInsets.fromLTRB(14, 14, 14, 28);

  // Text Styles
  static const TextStyle requiredProofTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle bulletText = TextStyle(fontSize: 12);

  static const TextStyle recipientLabel = TextStyle(fontSize: 12);

  static const TextStyle recipientValue = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle recipientHelper = TextStyle(fontSize: 12);

  static const TextStyle buyerConfirmationTitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle gpsText = TextStyle(
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
