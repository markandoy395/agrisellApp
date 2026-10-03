import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ProfileCardShellStyles {
  static final decoratedBoxDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.12),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ],
  );
}
