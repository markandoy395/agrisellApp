import 'package:flutter/material.dart';

import '../styles/buyer_settings_panel_styles.dart';

class BuyerSettingsActionTile extends StatelessWidget {
  const BuyerSettingsActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.destructive = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: BuyerSettingsPanelStyles.tilePadding,
      child: Row(
        children: [
          BuyerSettingsTileIcon(icon: icon, destructive: destructive),
          BuyerSettingsPanelStyles.tileSpacing,
          Expanded(
            child: BuyerSettingsTileLabel(
              title: title,
              subtitle: subtitle,
              destructive: destructive,
            ),
          ),
          BuyerSettingsPanelStyles.chevronSpacing,
          Icon(
            Icons.chevron_right_rounded,
            color: BuyerSettingsPanelStyles.tileChevronColor(
              destructive: destructive,
            ),
            size: BuyerSettingsPanelStyles.chevronSize,
          ),
        ],
      ),
    ),
  );
}

class BuyerSettingsTileIcon extends StatelessWidget {
  const BuyerSettingsTileIcon({
    required this.icon,
    this.destructive = false,
    super.key,
  });

  final IconData icon;
  final bool destructive;

  @override
  Widget build(BuildContext context) => Container(
    width: BuyerSettingsPanelStyles.iconBoxSize,
    height: BuyerSettingsPanelStyles.iconBoxSize,
    decoration: BuyerSettingsPanelStyles.tileIconDecoration(
      destructive: destructive,
    ),
    child: Icon(
      icon,
      color: BuyerSettingsPanelStyles.tileIconColor(
        destructive: destructive,
      ),
      size: BuyerSettingsPanelStyles.iconSize,
    ),
  );
}

class BuyerSettingsTileLabel extends StatelessWidget {
  const BuyerSettingsTileLabel({
    required this.title,
    this.subtitle,
    this.destructive = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final bool destructive;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: BuyerSettingsPanelStyles.tileTitleStyle(
          destructive: destructive,
        ),
      ),
      if (subtitle != null && subtitle!.isNotEmpty) ...[
        BuyerSettingsPanelStyles.subtitleSpacing,
        Text(
          subtitle!,
          style: BuyerSettingsPanelStyles.subtitleStyle,
        ),
      ],
    ],
  );
}
