import 'package:flutter/material.dart';

import 'package:agresell_app/core/models/user_profile.dart';
import '../styles/buyer_settings_panel_styles.dart';

class BuyerSettingsIdentityCard extends StatelessWidget {
  const BuyerSettingsIdentityCard({required this.profile, super.key});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) => Padding(
    padding: BuyerSettingsPanelStyles.identityMargin,
    child: Container(
      padding: BuyerSettingsPanelStyles.identityPadding,
      decoration: BuyerSettingsPanelStyles.identityCardDecoration,
      child: Row(
        children: [
          Container(
            width: BuyerSettingsPanelStyles.avatarSize,
            height: BuyerSettingsPanelStyles.avatarSize,
            decoration: BuyerSettingsPanelStyles.avatarDecoration,
            child: const Icon(
              Icons.person_rounded,
              color: BuyerSettingsPanelStyles.avatarIconColor,
              size: BuyerSettingsPanelStyles.avatarIconSize,
            ),
          ),
          BuyerSettingsPanelStyles.identityTextSpacing,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.headerName,
                  style: BuyerSettingsPanelStyles.identityNameStyle,
                ),
                BuyerSettingsPanelStyles.identityEmailSpacing,
                Text(
                  profile.email,
                  style: BuyerSettingsPanelStyles.identityEmailStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
