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
        style: FilledButton.styleFrom(
          backgroundColor: AgrisellColors.authBackground,
          disabledBackgroundColor: AgrisellColors.authBackground,
          foregroundColor: AgrisellColors.authGreen,
          disabledForegroundColor: AgrisellColors.authGreen,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          side: const BorderSide(color: AgrisellColors.forestSoft, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: AgrisellColors.limeSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 29, color: AgrisellColors.authGreen),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AgrisellColors.authGreen,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AgrisellColors.mutedText,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AgrisellColors.forestSoft,
                shape: BoxShape.circle,
              ),
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
