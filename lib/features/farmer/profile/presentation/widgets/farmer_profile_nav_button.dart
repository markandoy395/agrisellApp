import 'package:flutter/material.dart';

import '../styles/farmer_profile_header_styles.dart';

class FarmerProfileNavButton extends StatelessWidget {
  const FarmerProfileNavButton({
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
        borderRadius: FarmerProfileHeaderStyles.navButtonRadius,
        child: Container(
          width: FarmerProfileHeaderStyles.navButtonSize,
          height: FarmerProfileHeaderStyles.navButtonSize,
          decoration: FarmerProfileHeaderStyles.navButtonDecoration,
          child: Icon(
            icon,
            color: FarmerProfileHeaderStyles.navButtonIconColor,
            size: FarmerProfileHeaderStyles.navButtonIconSize,
          ),
        ),
      ),
    ),
  );
}
