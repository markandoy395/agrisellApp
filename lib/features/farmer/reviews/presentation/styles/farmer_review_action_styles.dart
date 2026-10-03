import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerReviewActionStyles {
  static const iconSize = 14.0;
  static const reportColor = Color(0xFFB82828);
  static const selectedLabel = TextStyle(
    color: AgrisellColors.surface,
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );
  static const unselectedLabel = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
  static final selectedShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: const BorderSide(color: AgrisellColors.authGreen),
  );
  static final unselectedShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: const BorderSide(color: Color(0xFFD6DFDB)),
  );
  static final appealButton = _button(
    foreground: AgrisellColors.authGreen,
    border: const Color(0xFFCDE4D7),
    background: const Color(0xFFF3FAF6),
  );
  static final reportButton = _button(
    foreground: reportColor,
    border: const Color(0xFFF5C6CB),
    background: const Color(0xFFFDF2F2),
  );

  static ButtonStyle _button({
    required Color foreground,
    required Color border,
    required Color background,
  }) => OutlinedButton.styleFrom(
    foregroundColor: foreground,
    side: BorderSide(color: border),
    backgroundColor: background,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}
