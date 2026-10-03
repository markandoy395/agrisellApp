import 'package:flutter/material.dart';

import '../styles/farmer_profile_header_styles.dart';

class FarmerProfileAvatar extends StatelessWidget {
  const FarmerProfileAvatar({
    required this.name,
    required this.isVerified,
    super.key,
  });

  final String name;
  final bool isVerified;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: '$name profile avatar',
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        // Glow ring
        Container(
          width: FarmerProfileHeaderStyles.avatarOuterSize,
          height: FarmerProfileHeaderStyles.avatarOuterSize,
          decoration: FarmerProfileHeaderStyles.avatarGlowDecoration,
          child: Container(
            decoration: FarmerProfileHeaderStyles.avatarInnerDecoration,
            child: const Icon(
              Icons.person_rounded,
              color: FarmerProfileHeaderStyles.avatarIconColor,
              size: FarmerProfileHeaderStyles.avatarIconSize,
            ),
          ),
        ),
        if (isVerified)
          Positioned(
            right: FarmerProfileHeaderStyles.verifiedBadgePositionRight,
            bottom: FarmerProfileHeaderStyles.verifiedBadgePositionBottom,
            child: Semantics(
              label: 'Verified',
              child: Container(
                width: FarmerProfileHeaderStyles.verifiedBadgeSize,
                height: FarmerProfileHeaderStyles.verifiedBadgeSize,
                decoration: FarmerProfileHeaderStyles.verifiedBadgeDecoration,
                child: const Icon(
                  Icons.check_rounded,
                  color: FarmerProfileHeaderStyles.verifiedBadgeIconColor,
                  size: FarmerProfileHeaderStyles.verifiedBadgeIconSize,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
