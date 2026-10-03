import 'package:flutter/material.dart';

import '../styles/buyer_settings_panel_styles.dart';

class BuyerSettingsGroup extends StatelessWidget {
  const BuyerSettingsGroup({
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
      padding: BuyerSettingsPanelStyles.groupPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: BuyerSettingsPanelStyles.groupLabelPadding,
            child: Text(
              title.toUpperCase(),
              style: BuyerSettingsPanelStyles.groupLabelStyle,
            ),
          ),
          Container(
            decoration: BuyerSettingsPanelStyles.groupDecoration,
            child: ClipRRect(
              borderRadius: BuyerSettingsPanelStyles.groupRadius,
              child: Column(
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    children[i],
                    if (i < children.length - 1)
                      BuyerSettingsPanelStyles.groupDivider,
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
