import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ProductEditImageHeaderStyles {
  static final decoratedBoxDecoration = BoxDecoration(
    color: AgrisellColors.brandBlack.withValues(alpha: 0.18),
  );

  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.surface.withValues(alpha: 0.33),
    shape: BoxShape.circle,
  );
}
