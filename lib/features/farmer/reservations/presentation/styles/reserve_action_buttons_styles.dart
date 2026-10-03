import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ReserveActionButtonsStyles {
  static final filledButtonStyle = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: AgrisellColors.surface,
    elevation: 3,
    shadowColor: AgrisellColors.brandBlack.withValues(alpha: 0.18),
    padding: const EdgeInsets.symmetric(horizontal: 14),
    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static final outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    side: const BorderSide(color: AgrisellColors.authGreen, width: 1.2),
    padding: const EdgeInsets.symmetric(horizontal: 14),
    textStyle: const TextStyle(
      fontSize: 12,
      height: 1,
      fontWeight: FontWeight.w800,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.statusGreenBackground,
    borderRadius: BorderRadius.circular(8),
  );

  static const movedToToShipText = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w800,
  );
}
