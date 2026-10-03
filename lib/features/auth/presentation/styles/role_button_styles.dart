import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RoleButtonStyles {
  static final filledButtonStyle = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authBackground,
    disabledBackgroundColor: AgrisellColors.authBackground,
    foregroundColor: AgrisellColors.authGreen,
    disabledForegroundColor: AgrisellColors.authGreen,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    side: const BorderSide(color: AgrisellColors.forestSoft, width: 1.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  );

  static const containerDecoration = BoxDecoration(
    color: AgrisellColors.limeSoft,
    shape: BoxShape.circle,
  );

  static const labelText = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static const descriptionText = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 13,
  );
}
