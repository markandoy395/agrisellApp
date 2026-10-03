import 'package:flutter/material.dart';

import 'package:agresell_app/features/buyer/profile/presentation/widgets/buyer_profile_style.dart';
import '../styles/profile_header_styles.dart';

class BuyerProfileHeaderNavButton extends StatelessWidget {
  const BuyerProfileHeaderNavButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
    super.key,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Semantics(
      button: true,
      label: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: ProfileHeaderStyles.navButtonBorderRadius,
        child: Container(
          width: ProfileHeaderStyles.navButtonSize,
          height: ProfileHeaderStyles.navButtonSize,
          decoration: ProfileHeaderStyles.navButtonDecoration,
          child: Icon(
            icon,
            color: BuyerProfileStyle.green,
            size: ProfileHeaderStyles.navButtonIconSize,
          ),
        ),
      ),
    ),
  );
}
