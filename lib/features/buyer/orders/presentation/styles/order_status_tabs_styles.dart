import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class OrderStatusTabsStyles {
  static final decoratedBoxDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.08),
        blurRadius: 14,
        offset: const Offset(0, 6),
      ),
    ],
  );

  static final tabBarDecoration = BoxDecoration(
    color: AgrisellColors.authGreen,
    borderRadius: BorderRadius.circular(8),
  );
}
