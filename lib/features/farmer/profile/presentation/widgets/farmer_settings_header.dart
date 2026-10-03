import 'package:flutter/material.dart';

import '../styles/farmer_settings_panel_styles.dart';

class FarmerSettingsHeader extends StatelessWidget {
  const FarmerSettingsHeader({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      FarmerSettingsPanelStyles.dragHandleSpacingTop,
      Center(
        child: Container(
          width: FarmerSettingsPanelStyles.dragHandleWidth,
          height: FarmerSettingsPanelStyles.dragHandleHeight,
          decoration: FarmerSettingsPanelStyles.dragHandleDecoration,
        ),
      ),
      FarmerSettingsPanelStyles.dragHandleSpacingBottom,
      Padding(
        padding: FarmerSettingsPanelStyles.headerPadding,
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Settings',
                style: FarmerSettingsPanelStyles.headerTitleStyle,
              ),
            ),
            Tooltip(
              message: 'Close settings',
              child: InkWell(
                onTap: onBack,
                borderRadius: FarmerSettingsPanelStyles.closeButtonRadius,
                child: Container(
                  width: FarmerSettingsPanelStyles.closeButtonSize,
                  height: FarmerSettingsPanelStyles.closeButtonSize,
                  decoration: FarmerSettingsPanelStyles.closeButtonDecoration,
                  child: const Icon(
                    Icons.close_rounded,
                    color: FarmerSettingsPanelStyles.closeIconColor,
                    size: FarmerSettingsPanelStyles.closeIconSize,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
