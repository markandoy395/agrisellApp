import 'package:flutter/material.dart';

import '../styles/buyer_settings_panel_styles.dart';

class BuyerSettingsHeader extends StatelessWidget {
  const BuyerSettingsHeader({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      BuyerSettingsPanelStyles.dragHandleSpacingTop,
      Center(
        child: Container(
          width: BuyerSettingsPanelStyles.dragHandleWidth,
          height: BuyerSettingsPanelStyles.dragHandleHeight,
          decoration: BuyerSettingsPanelStyles.dragHandleDecoration,
        ),
      ),
      BuyerSettingsPanelStyles.dragHandleSpacingBottom,
      Padding(
        padding: BuyerSettingsPanelStyles.headerPadding,
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Settings',
                style: BuyerSettingsPanelStyles.headerTitleStyle,
              ),
            ),
            Tooltip(
              message: 'Close settings',
              child: InkWell(
                onTap: onBack,
                borderRadius: BuyerSettingsPanelStyles.closeButtonRadius,
                child: Container(
                  width: BuyerSettingsPanelStyles.closeButtonSize,
                  height: BuyerSettingsPanelStyles.closeButtonSize,
                  decoration: BuyerSettingsPanelStyles.closeButtonDecoration,
                  child: const Icon(
                    Icons.close_rounded,
                    color: BuyerSettingsPanelStyles.closeIconColor,
                    size: BuyerSettingsPanelStyles.closeIconSize,
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
