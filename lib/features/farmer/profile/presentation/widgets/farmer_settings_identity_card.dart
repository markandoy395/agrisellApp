import 'package:flutter/material.dart';

import 'package:agresell_app/core/models/user_profile.dart';
import '../styles/farmer_settings_panel_styles.dart';

class FarmerSettingsIdentityCard extends StatelessWidget {
  const FarmerSettingsIdentityCard({required this.profile, super.key});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) => Padding(
    padding: FarmerSettingsPanelStyles.identityMargin,
    child: Container(
      padding: FarmerSettingsPanelStyles.identityPadding,
      decoration: FarmerSettingsPanelStyles.identityCardDecoration,
      child: Row(
        children: [
          Container(
            width: FarmerSettingsPanelStyles.avatarSize,
            height: FarmerSettingsPanelStyles.avatarSize,
            decoration: FarmerSettingsPanelStyles.avatarDecoration,
            child: const Icon(
              Icons.person_rounded,
              color: FarmerSettingsPanelStyles.avatarIconColor,
              size: FarmerSettingsPanelStyles.avatarIconSize,
            ),
          ),
          FarmerSettingsPanelStyles.identityTextSpacing,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.headerName,
                  style: FarmerSettingsPanelStyles.identityNameStyle,
                ),
                FarmerSettingsPanelStyles.identityEmailSpacing,
                Text(
                  profile.email,
                  style: FarmerSettingsPanelStyles.identityEmailStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
