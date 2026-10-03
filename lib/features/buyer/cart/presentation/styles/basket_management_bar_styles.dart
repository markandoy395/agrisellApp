import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class BasketManagementBarStyles {
  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(20),
  );

  static const textStyle = TextStyle(
    color: AgrisellColors.forestDark,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static final textButtonStyle = TextButton.styleFrom(
    foregroundColor: AgrisellColors.statusRedText,
    disabledForegroundColor: AgrisellColors.mutedText,
    minimumSize: const Size(0, 36),
    padding: const EdgeInsets.symmetric(horizontal: 8),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}
