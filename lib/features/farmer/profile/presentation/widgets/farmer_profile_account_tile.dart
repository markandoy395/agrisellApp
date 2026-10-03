import 'package:flutter/material.dart';

import '../styles/farmer_profile_screen_styles.dart';

class FarmerProfileAccountTile extends StatelessWidget {
  const FarmerProfileAccountTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.destructive = false,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: FarmerProfileScreenStyles.tileRadius,
    child: Padding(
      padding: FarmerProfileScreenStyles.tilePadding,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: destructive
                ? FarmerProfileScreenStyles.destructiveTileIcon
                : FarmerProfileScreenStyles.tileIcon,
            child: Icon(
              icon,
              color: destructive
                  ? FarmerProfileScreenStyles.destructiveColor
                  : FarmerProfileScreenStyles.iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: subtitle?.isNotEmpty == true
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: destructive
                            ? FarmerProfileScreenStyles.destructiveTileTitle
                            : FarmerProfileScreenStyles.tileTitle,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: FarmerProfileScreenStyles.subtitle,
                      ),
                    ],
                  )
                : Text(
                    title,
                    style: destructive
                        ? FarmerProfileScreenStyles.destructiveTileTitle
                        : FarmerProfileScreenStyles.tileTitle,
                  ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right_rounded,
            color: destructive
                ? FarmerProfileScreenStyles.destructiveColor
                : FarmerProfileScreenStyles.chevronColor,
            size: 22,
          ),
        ],
      ),
    ),
  );
}
