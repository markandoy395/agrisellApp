import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class AccountFoundDialogStyles {
  static const containerDecoration = BoxDecoration(
    color: Color(0xFFE8F5EB),
    shape: BoxShape.circle,
  );

  static const accountFoundText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
  );

  static const textStyle = TextStyle(
    fontSize: 13,
    color: AgrisellColors.mutedText,
  );

  static final filledButtonStyle = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    minimumSize: const Size(0, 44),
    maximumSize: const Size(double.infinity, 44),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );

  static final outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    side: const BorderSide(color: AgrisellColors.authGreen),
    minimumSize: const Size(0, 40),
    maximumSize: const Size(double.infinity, 40),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );
}
