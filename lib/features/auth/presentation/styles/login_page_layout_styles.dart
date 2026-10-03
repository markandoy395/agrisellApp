import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class LoginPageLayoutStyles {
  static final iconButtonStyle = IconButton.styleFrom(
    backgroundColor: AgrisellColors.forestSoft,
    foregroundColor: AgrisellColors.headingGreen,
  );

  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: .09),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static TextStyle titleText(Color titleColor) => TextStyle(
    color: titleColor,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.15,
  );

  static const textStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 14,
  );
}
