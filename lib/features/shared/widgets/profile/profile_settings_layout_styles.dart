import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_text_styles.dart';

abstract final class ProfileSettingsLayoutStyles {
  static final decoratedBoxDecoration = BoxDecoration(
    color: AgrisellColors.limeSoft,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AgrisellColors.borderLine),
  );

  static const decoratedBoxDecoration2 = BoxDecoration(
    color: AgrisellColors.authGreen,
    shape: BoxShape.circle,
  );

  static TextStyle nameText(BuildContext context) =>
      ProfileTextStyles.infoLabel(
        context,
      ).copyWith(fontWeight: FontWeight.w700, height: 1.1);

  static TextStyle emailText(BuildContext context) =>
      ProfileTextStyles.profileDescription(
        context,
      ).copyWith(fontSize: 12, height: 1.2);

  static const titleText = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );
}
