import 'package:agresell_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class NotificationStateViewStyles {
  static final retryButton = OutlinedButton.styleFrom(
    minimumSize: const Size(64, 48),
    maximumSize: Size.infinite,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  );

  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: AgrisellColors.borderLine),
  );

  static final containerDecoration2 = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(16),
  );

  static const textText = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w500,
  );
}
