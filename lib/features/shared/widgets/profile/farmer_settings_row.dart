import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_text_styles.dart';

class FarmerSettingsActionRow extends StatelessWidget {
  const FarmerSettingsActionRow({
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

    return _FarmerSettingsRowShell(
      icon: icon,
      title: title,
      subtitle: subtitle,
      iconColor: color,
      titleColor: isDestructive ? color : AgrisellColors.brandBlack,
      onTap: onTap,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: color.withValues(alpha: 0.78),
        size: 20,
      ),
    );
  }
}

class _FarmerSettingsRowShell extends StatelessWidget {
  const _FarmerSettingsRowShell({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
    this.iconColor = AgrisellColors.authGreen,
    this.titleColor = AgrisellColors.brandBlack,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onTap;
  final Color iconColor;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
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
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SizedBox.square(
                  dimension: 34,
                  child: Icon(icon, color: iconColor, size: 19),
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
                      style: _settingsTitle(
                        context,
                      ).copyWith(color: titleColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _settingsSubtitle(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

TextStyle _settingsTitle(BuildContext context) {
  return ProfileTextStyles.infoLabel(
    context,
  ).copyWith(fontWeight: FontWeight.w700, height: 1.1);
}

TextStyle _settingsSubtitle(BuildContext context) {
  return ProfileTextStyles.profileDescription(
    context,
  ).copyWith(fontSize: 12, height: 1.2);
}
