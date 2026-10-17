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

  static  Widget? fieldIcon(
    String label,
    bool show,
    Widget Function(IconData)? builder,
  ) {
    if (!show) return null;
    final icon = switch (label) {
      'Province' => Icons.map_outlined,
      'Barangay' => Icons.home_outlined,
      _ => Icons.location_city_outlined,
    };
    return builder?.call(icon) ?? Icon(icon, color: iconColor);
  }
}
