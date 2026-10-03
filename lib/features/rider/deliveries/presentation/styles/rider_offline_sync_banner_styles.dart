import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderOfflineSyncBannerStyles {
  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: AgrisellColors.borderLine),
  );

  static const textStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 12,
    height: 1.25,
    fontWeight: FontWeight.w700,
  );

  static final textButtonStyle = TextButton.styleFrom(
    minimumSize: const Size(0, 38),
    padding: const EdgeInsets.symmetric(horizontal: 10),
  );
}
