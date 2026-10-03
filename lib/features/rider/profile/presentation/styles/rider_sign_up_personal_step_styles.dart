import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderSignUpPersonalStepStyles {
  static final _animatedContainerDecorationActive = BoxDecoration(
    color: AgrisellColors.authGreen.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AgrisellColors.authGreen),
  );
  static final _animatedContainerDecorationInactive = BoxDecoration(
    color: AgrisellColors.fieldFill,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AgrisellColors.borderLine),
  );
  static BoxDecoration animatedContainerDecoration(bool isSelected) =>
      isSelected
      ? _animatedContainerDecorationActive
      : _animatedContainerDecorationInactive;
}
