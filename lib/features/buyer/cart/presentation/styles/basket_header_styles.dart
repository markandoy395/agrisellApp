import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class BasketHeaderStyles {
  static final containerDecoration = BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AgrisellColors.forestDark, AgrisellColors.authGreen],
    ),
    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.forestDark.withValues(alpha: 0.2),
        blurRadius: 18,
        offset: const Offset(0, 7),
      ),
    ],
  );

  static const basketText = TextStyle(
    color: AgrisellColors.surface,
    fontSize: 15,
    height: 1.05,
    fontWeight: FontWeight.w800,
  );

  static final textStyle = TextStyle(
    color: AgrisellColors.surface.withValues(alpha: 0.78),
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w500,
  );
}
