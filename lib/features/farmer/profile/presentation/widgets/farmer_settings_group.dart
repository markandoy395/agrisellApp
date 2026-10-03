import 'package:flutter/material.dart';

import '../styles/farmer_settings_panel_styles.dart';

class FarmerSettingsGroup extends StatelessWidget {
  const FarmerSettingsGroup({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: FarmerSettingsPanelStyles.groupPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: FarmerSettingsPanelStyles.groupLabelPadding,
            child: Text(
              title.toUpperCase(),
              style: FarmerSettingsPanelStyles.groupLabelStyle,
            ),
          ),
          Container(
            decoration: FarmerSettingsPanelStyles.groupDecoration,
            child: ClipRRect(
              borderRadius: FarmerSettingsPanelStyles.groupRadius,
              child: Column(
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    children[i],
                    if (i < children.length - 1)
                      FarmerSettingsPanelStyles.groupDivider,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
