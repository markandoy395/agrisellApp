import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerProfileCardStyles {
  static final decoratedBoxDecoration = BoxDecoration(
    color: AgrisellColors.authGreen,
    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.18),
        blurRadius: 14,
        offset: const Offset(0, 7),
      ),
    ],
  );

  static final textStyle = TextStyle(
    color: AgrisellColors.surface.withValues(alpha: 0.88),
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static final outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.surface,
    side: const BorderSide(color: AgrisellColors.surface, width: 1.4),
    shape: const StadiumBorder(),
    padding: const EdgeInsets.symmetric(horizontal: 7),
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    textStyle: const TextStyle(
      fontSize: 12,
      height: 1,
      fontWeight: FontWeight.w600,
    ),
  );
}
