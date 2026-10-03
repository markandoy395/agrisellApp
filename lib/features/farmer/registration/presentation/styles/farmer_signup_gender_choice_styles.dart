import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerSignupGenderChoiceStyles {
  static const genderText = TextStyle(
    color: Color(0xFF075239),
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static final _animatedContainerDecorationActive = BoxDecoration(
    color: AgrisellColors.authGreen.withValues(alpha: 0.06),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AgrisellColors.authGreen),
  );
  static final _animatedContainerDecorationInactive = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AgrisellColors.borderLine),
  );
  static BoxDecoration animatedContainerDecoration(bool isSelected) =>
      isSelected
      ? _animatedContainerDecorationActive
      : _animatedContainerDecorationInactive;

  static const containerDecoration = BoxDecoration(
    color: Color(0xFFEDF8F0),
    shape: BoxShape.circle,
  );
}
