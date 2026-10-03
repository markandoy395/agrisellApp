import 'package:flutter/material.dart';

import '../styles/profile_header_styles.dart';
import 'buyer_profile_header_nav_button.dart';

class BuyerProfileHeaderTopBar extends StatelessWidget {
  const BuyerProfileHeaderTopBar({
    required this.title,
    this.onBack,
    this.onSettingsTap,
    this.showSettingsIcon = false,
    this.onBasketTap,
    super.key,
  });

  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onSettingsTap;
  final bool showSettingsIcon;
  final VoidCallback? onBasketTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ProfileHeaderStyles.topBarPadding,
      child: Row(
        children: [
          if (onBack != null) ...[
            BuyerProfileHeaderNavButton(
              tooltip: 'Back',
              onPressed: onBack!,
              icon: Icons.arrow_back_ios_new_rounded,
            ),
            const SizedBox(width: ProfileHeaderStyles.topBarGap),
          ],
          Expanded(
            child: Text(
              title,
              style: ProfileHeaderStyles.title,
            ),
          ),
          if (onBasketTap != null)
            BuyerProfileHeaderNavButton(
              tooltip: 'Cart',
              onPressed: onBasketTap!,
              icon: Icons.shopping_cart_outlined,
            ),
          if (showSettingsIcon && onSettingsTap != null) ...[
            const SizedBox(width: ProfileHeaderStyles.settingsGap),
            BuyerProfileHeaderNavButton(
              tooltip: 'Settings',
              onPressed: onSettingsTap!,
              icon: Icons.tune_rounded,
            ),
          ],
        ],
      ),
    );
  }
}
