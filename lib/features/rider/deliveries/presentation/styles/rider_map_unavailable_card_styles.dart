import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderMapUnavailableCardStyles {
  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.statusBlueBackground,
    borderRadius: BorderRadius.circular(16),
  );

  static const titleText = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static final filledButtonStyle = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.forestGreen,
    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
  );

  static const textStyle = TextStyle(
    color: AgrisellColors.forestGreen,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
}
