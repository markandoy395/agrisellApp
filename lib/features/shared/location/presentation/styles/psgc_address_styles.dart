import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

/// Predefined style constants for PSGC address fields.
abstract final class PsgcAddressStyles {
  // Padding & Insets
  static const EdgeInsets regionPadding = EdgeInsets.fromLTRB(4, 0, 4, 8);

  // Typography
  static const TextStyle regionText = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
  );

  // Icon Colors
  static const Color iconColor = AgrisellColors.mutedText;
}
