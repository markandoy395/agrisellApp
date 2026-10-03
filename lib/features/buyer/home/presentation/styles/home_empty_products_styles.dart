import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class HomeEmptyProductsStyles {
  static final titleText = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 14,
    fontWeight: FontWeight.w800,
  );

  static final messageText = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.35,
  );

  static final outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    side: const BorderSide(color: AgrisellColors.authGreen),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}
