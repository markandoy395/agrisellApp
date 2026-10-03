import 'package:agresell_app/features/shared/widgets/profile/profile_settings_action_row_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

class ProfileSettingsActionRow extends StatelessWidget {
  const ProfileSettingsActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AgrisellColors.statusRedText
        : AgrisellColors.authGreen;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              DecoratedBox(
                decoration:
                    ProfileSettingsActionRowStyles.decoratedBoxDecoration(
                      color,
                    ),
                child: SizedBox.square(
                  dimension: 34,
                  child: Icon(icon, color: color, size: 19),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ProfileSettingsActionRowStyles.titleText(
                        context,
                        isDestructive,
                        color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ProfileSettingsActionRowStyles.subtitleText(
                        context,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: color.withValues(alpha: 0.78),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
