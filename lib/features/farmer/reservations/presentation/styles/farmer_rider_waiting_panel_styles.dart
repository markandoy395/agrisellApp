import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerRiderWaitingPanelStyles {
  static final decoratedBoxDecoration = BoxDecoration(
    color: AgrisellColors.statusGreenBackground,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: AgrisellColors.authGreen.withValues(alpha: 0.28)),
  );

  static const textStyle = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w500,
  );

  static const containerDecoration = BoxDecoration(
    color: AgrisellColors.authGreen,
    shape: BoxShape.circle,
  );
}
