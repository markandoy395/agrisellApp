import 'package:flutter/material.dart';

import '../widgets/farmer_profile_style.dart';

abstract final class FarmerProfileHeaderStyles {
  // Top bar
  static const topBarPadding = EdgeInsets.fromLTRB(4, 0, 4, 14);
  static const spacingNavButton = SizedBox(width: 12);
  static const titleStyle = TextStyle(
    color: FarmerProfileStyle.ink,
    fontSize: 15,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  // Nav button
  static const navButtonSize = 44.0;
  static final navButtonRadius = BorderRadius.circular(13);
  static final navButtonDecoration = BoxDecoration(
    color: FarmerProfileStyle.mint,
    borderRadius: navButtonRadius,
    border: Border.all(color: FarmerProfileStyle.borderSubtle, width: 1),
  );
  static const navButtonIconColor = FarmerProfileStyle.green;
  static const navButtonIconSize = 20.0;

  // Hero banner
  static final bannerRadius = BorderRadius.circular(22);
  static const heroBannerDecoration = BoxDecoration(
    gradient: FarmerProfileStyle.heroGradient,
  );
  static const bannerPadding = EdgeInsets.all(16);
  static const spacingAvatar = SizedBox(width: 14);

  // Avatar
  static const avatarOuterSize = 88.0;
  static final avatarGlowDecoration = BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.25),
      width: 2.5,
    ),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF0E6B43).withValues(alpha: 0.6),
        blurRadius: 20,
        spreadRadius: 2,
      ),
    ],
  );
  static const avatarInnerDecoration = BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
      colors: [Color(0xFF1A7A52), Color(0xFF0E5C38)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
  static const avatarIconColor = Color(0xFFB8F0D6);
  static const avatarIconSize = 52.0;

  // Verified avatar badge
  static const verifiedBadgeSize = 26.0;
  static final verifiedBadgeDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFF1BB871), Color(0xFF08683F)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    shape: BoxShape.circle,
    border: Border.all(color: Colors.white, width: 2.5),
  );
  static const verifiedBadgeIconColor = Colors.white;
  static const verifiedBadgeIconSize = 15.0;
  static const verifiedBadgePositionRight = -2.0;
  static const verifiedBadgePositionBottom = 2.0;

  // Profile text & badges
  static const nameStyle = TextStyle(
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.2,
  );
  static const spacingVerifiedBadge = SizedBox(height: 6);
  static const verifiedBadgePadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 4,
  );
  static const verifiedIconColor = Color(0xFF6FFAB3);
  static const verifiedIconSize = 13.0;
  static const spacingVerifiedText = SizedBox(width: 5);
  static final verifiedTextStyle = TextStyle(
    color: Colors.white.withValues(alpha: 0.9),
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  // Follower stats
  static const spacingStats = SizedBox(height: 8);
  static const pillWrapSpacing = 6.0;
  static const pillWrapRunSpacing = 4.0;
  static const statPillPadding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 4,
  );
  static const statValueStyle = TextStyle(
    color: Colors.white,
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );
  static final statLabelStyle = TextStyle(
    color: Colors.white.withValues(alpha: 0.7),
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // Background pattern painter
  static final patternCircleColor = Colors.white.withValues(alpha: 0.04);
  static final patternLeafColor = Colors.white.withValues(alpha: 0.055);
  static const circleBlurFilter = MaskFilter.blur(BlurStyle.normal, 30);
}
