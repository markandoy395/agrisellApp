import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

/// Predefined styling constants for the rider delivery details screen and content.
abstract final class RiderDeliveryDetailsStyles {
  // Padding & Insets
  static const EdgeInsets listPadding = EdgeInsets.fromLTRB(14, 14, 14, 28);

  // Spacing
  static const double spacing12 = 12.0;
  static const double spacing14 = 14.0;

  // Waybill Button
  static const double waybillButtonHeight = 40.0;
  static const double waybillButtonIconSize = 16.0;

  static const TextStyle waybillButtonText = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 12,
  );

  static final ButtonStyle waybillButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    backgroundColor: AgrisellColors.surface,
    side: const BorderSide(color: AgrisellColors.borderLine),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );
}
