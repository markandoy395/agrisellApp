import 'package:agresell_app/features/shared/widgets/profile/profile_edit_action_button_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

class ProfileEditActionButton extends StatelessWidget {
  const ProfileEditActionButton({
    required this.label,
    required this.onPressed,
    required this.isPrimary,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final background = isPrimary
        ? AgrisellColors.authGreen
        : AgrisellColors.surface;
    final foreground = isPrimary
        ? AgrisellColors.surface
        : AgrisellColors.authGreen;

    return SizedBox(
      width: 100,
      height: 36,
      child: OutlinedButton(
        onPressed: onPressed,
        style: ProfileEditActionButtonStyles.outlinedButtonStyle(
          background,
          foreground,
        ),
        child: Text(
          label,
          style: ProfileEditActionButtonStyles.labelText(context, foreground),
        ),
      ),
    );
  }
}
