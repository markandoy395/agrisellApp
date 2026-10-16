import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../styles/rider_profile_design_styles.dart';

class RiderSettingsAction extends StatelessWidget {
  const RiderSettingsAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color = AgrisellColors.authGreen,
    super.key,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;
  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 6),
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: RiderProfileDesignStyles.badge(color),
        child: Icon(icon, color: color, size: 25),
      ),
      title: Text(title, style: RiderProfileDesignStyles.body),
      subtitle: Text(subtitle, style: RiderProfileDesignStyles.caption),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AgrisellColors.mutedText,
      ),
    ),
  );
}
