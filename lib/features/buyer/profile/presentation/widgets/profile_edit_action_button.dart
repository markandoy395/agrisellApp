import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_text_styles.dart';

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
        style: OutlinedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          side: const BorderSide(color: AgrisellColors.authGreen, width: 1.4),
          shape: const StadiumBorder(),
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          label,
          style: ProfileTextStyles.editButton(
            context,
          ).copyWith(color: foreground),
        ),
      ),
    );
  }
}
