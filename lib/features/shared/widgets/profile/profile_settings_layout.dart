import 'package:agresell_app/features/shared/widgets/profile/profile_settings_layout_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_section_label.dart';

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
      decoration: ProfileSettingsLayoutStyles.decoratedBoxDecoration,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const DecoratedBox(
              decoration: ProfileSettingsLayoutStyles.decoratedBoxDecoration2,
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
                    style: ProfileSettingsLayoutStyles.nameText(context),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ProfileSettingsLayoutStyles.emailText(context),
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
        Text(title, style: ProfileSettingsLayoutStyles.titleText),
        const SizedBox(height: 3),
        for (var index = 0; index < children.length; index++) ...[
          children[index],
          if (index < children.length - 1) const Divider(height: 1),
        ],
      ],
    );
  }
}
