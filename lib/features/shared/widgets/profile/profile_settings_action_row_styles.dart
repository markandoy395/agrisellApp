import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_text_styles.dart';

abstract final class ProfileSettingsActionRowStyles {
  static BoxDecoration decoratedBoxDecoration(Color color) => BoxDecoration(
    color: color.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(8),
  );

  static TextStyle titleText(
    BuildContext context,
    bool isDestructive,
    Color color,
  ) => ProfileTextStyles.infoLabel(context).copyWith(
    color: isDestructive ? color : AgrisellColors.brandBlack,
    fontWeight: FontWeight.w700,
    height: 1.1,
  );

  static TextStyle subtitleText(BuildContext context) =>
      ProfileTextStyles.profileDescription(
        context,
      ).copyWith(fontSize: 12, height: 1.2);
}
