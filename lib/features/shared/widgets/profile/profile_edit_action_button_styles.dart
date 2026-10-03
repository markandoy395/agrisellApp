import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_text_styles.dart';

abstract final class ProfileEditActionButtonStyles {
  static ButtonStyle outlinedButtonStyle(Color background, Color foreground) =>
      OutlinedButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        side: const BorderSide(color: AgrisellColors.authGreen, width: 1.4),
        shape: const StadiumBorder(),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );

  static TextStyle labelText(BuildContext context, Color foreground) =>
      ProfileTextStyles.editButton(context).copyWith(color: foreground);
}
