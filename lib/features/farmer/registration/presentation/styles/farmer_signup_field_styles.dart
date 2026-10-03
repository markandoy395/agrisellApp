import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerSignupFieldStyles {
  // Field styles
  static const errorPadding = EdgeInsets.only(top: 3, left: 4);
  static const bottomSpacing = SizedBox(height: 8);

  static const errorStyle = TextStyle(
    color: AgrisellColors.statusRedText,
    fontSize: 12,
  );

  // Picker styles
  static const pickerCardColor = Color(0xFFF1FAF5);
  static const pickerIconBoxColor = Color(0xFFE5F4EB);
  static const pickerDarkGreen = Color(0xFF075239);
  static const pickerBorderColor = Color(0xFFB8DEC8);
  static final pickerBorderRadius = BorderRadius.circular(16);
  static const pickerPadding = EdgeInsets.symmetric(horizontal: 18, vertical: 18);

  static const pickerTitleStyle = TextStyle(
    color: Color(0xFF075239),
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static const pickerSubtitleStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 11,
  );

  static const pickerCircleSize = 54.0;
  static const pickerIconSize = 32.0;
  static const pickerBadgeSize = 24.0;
  static final pickerButtonStyle = OutlinedButton.styleFrom(
    minimumSize: const Size(0, 38),
  );
}
