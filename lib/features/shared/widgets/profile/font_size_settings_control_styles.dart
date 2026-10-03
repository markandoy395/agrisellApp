import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_text_styles.dart';

abstract final class FontSizeSettingsControlStyles {
  static final decoratedBoxDecoration = BoxDecoration(
    color: AgrisellColors.authGreen.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(8),
  );

  static TextStyle fontSizeText(BuildContext context) =>
      ProfileTextStyles.infoLabel(context).copyWith(
        color: AgrisellColors.brandBlack,
        fontWeight: FontWeight.w700,
        height: 1.1,
      );

  static TextStyle textStyle(BuildContext context) =>
      ProfileTextStyles.profileDescription(
        context,
      ).copyWith(fontSize: 12, height: 1.2);
}
