import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

class RoleButton extends StatelessWidget {
  const RoleButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 238),
        child: SizedBox(
          width: double.infinity,
          height: 38,
          child: FilledButton(
            onPressed: isLoading ? null : onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: AgrisellColors.authGreen,
              disabledBackgroundColor: AgrisellColors.authGreen,
              foregroundColor: AgrisellColors.surface,
              disabledForegroundColor: AgrisellColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: isLoading
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AgrisellColors.surface,
                    ),
                  )
                : Text(label),
          ),
        ),
      ),
    );
  }
}
