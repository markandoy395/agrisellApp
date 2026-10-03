import 'package:agresell_app/features/auth/presentation/styles/role_button_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

class RoleButton extends StatelessWidget {
  const RoleButton({
    required this.label,
    required this.description,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final String description;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 72,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: RoleButtonStyles.filledButtonStyle,
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: RoleButtonStyles.containerDecoration,
              child: Icon(icon, size: 29, color: AgrisellColors.authGreen),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: RoleButtonStyles.labelText),
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: RoleButtonStyles.descriptionText,
                  ),
                ],
              ),
            ),
            Container(
              width: 42,
              height: 42,
              decoration: SharedPresentationStyles.forestCircle,
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AgrisellColors.authGreen,
                      ),
                    )
                  : const Icon(
                      Icons.chevron_right,
                      size: 30,
                      color: AgrisellColors.authGreen,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
