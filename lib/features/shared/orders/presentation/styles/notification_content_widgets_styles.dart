import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class NotificationContentWidgetsStyles {
  static final readAllButton = TextButton.styleFrom(
    minimumSize: const Size(48, 48),
    maximumSize: Size.infinite,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  );

  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.08),
        blurRadius: 14,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static final containerDecoration2 = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(12),
  );
}
