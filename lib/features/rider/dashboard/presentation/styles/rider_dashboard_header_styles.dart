import 'package:agresell_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderDashboardHeaderStyles {
  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.surface.withValues(alpha: 0.14),
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: AgrisellColors.surface.withValues(alpha: 0.2)),
  );

  static const statuslabelText = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.surface,
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );

  static final iconButtonStyle = IconButton.styleFrom(
    foregroundColor: AgrisellColors.surface,
    backgroundColor: AgrisellColors.surface.withValues(alpha: 0.14),
  );

  static final containerDecoration2 = BoxDecoration(
    color: AgrisellColors.accentOrange,
    borderRadius: BorderRadius.circular(999),
    border: Border.all(color: AgrisellColors.authGreen),
  );

  static const textStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w800,
  );
}
