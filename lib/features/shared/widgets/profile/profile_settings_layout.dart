import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_section_label.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_text_styles.dart';

class ProfileSettingsHeader extends StatelessWidget {
  const ProfileSettingsHeader({this.onClose, super.key});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const ProfileSectionLabel(text: 'Settings'),
        const Spacer(),
        if (onClose != null) ...[
          IconButton(
            tooltip: 'Close settings',
            constraints: const BoxConstraints.tightFor(width: 38, height: 38),
            padding: EdgeInsets.zero,
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, size: 22),
          ),
          const SizedBox(width: 7),
        ],
      ],
    );
  }
}

class ProfileSettingsAccountSummary extends StatelessWidget {
  const ProfileSettingsAccountSummary({
    required this.name,
    required this.email,
    super.key,
  });

  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AgrisellColors.limeSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AgrisellColors.borderLine),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                color: AgrisellColors.authGreen,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: 34,
                child: Icon(
                  Icons.manage_accounts_rounded,
                  color: AgrisellColors.surface,
                  size: 19,
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ProfileTextStyles.infoLabel(
                      context,
                    ).copyWith(fontWeight: FontWeight.w700, height: 1.1),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ProfileTextStyles.profileDescription(
                      context,
                    ).copyWith(fontSize: 12, height: 1.2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileSettingsGroup extends StatelessWidget {
  const ProfileSettingsGroup({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AgrisellColors.headingGreen,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        for (var index = 0; index < children.length; index++) ...[
          children[index],
          if (index < children.length - 1) const Divider(height: 1),
        ],
      ],
    );
  }
}
