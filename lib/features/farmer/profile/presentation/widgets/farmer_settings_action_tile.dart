import 'package:flutter/material.dart';

import '../styles/farmer_settings_panel_styles.dart';

class FarmerSettingsActionTile extends StatelessWidget {
  const FarmerSettingsActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: FarmerSettingsPanelStyles.tilePadding,
      child: Row(
        children: [
          FarmerSettingsTileIcon(icon: icon, destructive: destructive),
          FarmerSettingsPanelStyles.tileSpacing,
          Expanded(
            child: FarmerSettingsTileLabel(
              title: title,
              subtitle: subtitle,
              destructive: destructive,
            ),
          ),
          FarmerSettingsPanelStyles.chevronSpacing,
          Icon(
            Icons.chevron_right_rounded,
            color: FarmerSettingsPanelStyles.tileChevronColor(
              destructive: destructive,
            ),
            size: FarmerSettingsPanelStyles.chevronSize,
          ),
        ],
      ),
    ),
  );
}

class FarmerSettingsTileIcon extends StatelessWidget {
  const FarmerSettingsTileIcon({
    required this.icon,
    this.destructive = false,
    super.key,
  });

  final IconData icon;
  final bool destructive;

  @override
  Widget build(BuildContext context) => Container(
    width: FarmerSettingsPanelStyles.iconBoxSize,
    height: FarmerSettingsPanelStyles.iconBoxSize,
    decoration: FarmerSettingsPanelStyles.tileIconDecoration(
      destructive: destructive,
    ),
    child: Icon(
      icon,
      color: FarmerSettingsPanelStyles.tileIconColor(
        destructive: destructive,
      ),
      size: FarmerSettingsPanelStyles.iconSize,
    ),
  );
}

class FarmerSettingsTileLabel extends StatelessWidget {
  const FarmerSettingsTileLabel({
    required this.title,
    required this.subtitle,
    this.destructive = false,
    super.key,
  });

  final String title;
  final String subtitle;
  final bool destructive;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: FarmerSettingsPanelStyles.tileTitleStyle(
          destructive: destructive,
        ),
      ),
      FarmerSettingsPanelStyles.subtitleSpacing,
      Text(
        subtitle,
        style: FarmerSettingsPanelStyles.subtitleStyle,
      ),
    ],
  );
}
