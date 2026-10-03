import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class EmptyOrderStateStyles {
  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.08),
        blurRadius: 16,
        offset: const Offset(0, 7),
      ),
    ],
  );
}
