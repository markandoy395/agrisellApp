import 'package:flutter/material.dart';

import 'package:agresell_app/features/buyer/profile/presentation/widgets/buyer_profile_style.dart';

abstract final class ProfileHeaderStyles {
  // Colors
  static const Color verifiedIconColor = Color(0xFF6FFAB3);
  static const Color avatarGlowColor = Color(0xFF0E6B43);
  static const Color avatarPlaceholderIconColor = Color(0xFFB8F0D6);
  static const Color verifiedBadgeIconColor = Colors.white;

  // Dimensions & Sizes
  static const double navButtonSize = 44.0;
  static const double navButtonIconSize = 20.0;
  static const double navButtonRadius = 13.0;
  static const double topBarGap = 12.0;
  static const double settingsGap = 8.0;

  static const double heroRadius = 22.0;
  static const double heroAvatarGap = 14.0;
  static const double nameBadgeGap = 6.0;
  static const double badgeFollowersGap = 8.0;
  static const double badgeIconGap = 5.0;
  static const double verifiedChipIconSize = 13.0;

  static const double statPillSpacing = 6.0;
  static const double statPillRunSpacing = 4.0;

  static const double avatarSize = 88.0;
  static const double avatarGlowBorderWidth = 2.5;
  static const double avatarPlaceholderIconSize = 52.0;
  static const double editBadgeSize = 28.0;
  static const double verifiedBadgeSize = 26.0;
  static const double badgeIconSize = 15.0;
  static const double editBadgeBorderWidth = 2.0;
  static const double verifiedBadgeBorderWidth = 2.5;
  static const double badgeBottomOffset = 2.0;
  static const double badgeRightOffset = -2.0;

  // Paddings
  static const EdgeInsets topBarPadding = EdgeInsets.fromLTRB(4, 0, 4, 14);
  static const EdgeInsets heroPadding = EdgeInsets.all(16);
  static const EdgeInsets badgeChipPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 4,
  );
  static const EdgeInsets statPillPadding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 4,
  );

  // Text Styles
  static const TextStyle title = TextStyle(
    fontFamily: 'Poppins',
    color: BuyerProfileStyle.ink,
    fontSize: 15,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  static const TextStyle heroName = TextStyle(
    fontFamily: 'Poppins',
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.2,
  );

  static final TextStyle verifiedBadgeText = TextStyle(
    fontFamily: 'Poppins',
    color: Colors.white.withValues(alpha: 0.9),
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle statPillValue = TextStyle(
    fontFamily: 'Poppins',
    color: Colors.white,
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );

  static final TextStyle statPillLabel = TextStyle(
    fontFamily: 'Poppins',
    color: Colors.white.withValues(alpha: 0.7),
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // Borders & Decorations
  static final BorderRadius navButtonBorderRadius = BorderRadius.circular(
    navButtonRadius,
  );
  static final BorderRadius heroBorderRadius = BorderRadius.circular(heroRadius);
  static final BorderRadius editBadgeRadius = BorderRadius.circular(15);

  static final BoxDecoration navButtonDecoration = BoxDecoration(
    color: BuyerProfileStyle.mint,
    borderRadius: navButtonBorderRadius,
    border: Border.all(color: BuyerProfileStyle.borderSubtle, width: 1),
  );

  static const BoxDecoration heroDecoration = BoxDecoration(
    gradient: BuyerProfileStyle.heroGradient,
  );

  static final BoxDecoration avatarGlowDecoration = BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.25),
      width: avatarGlowBorderWidth,
    ),
    boxShadow: [
      BoxShadow(
        color: avatarGlowColor.withValues(alpha: 0.6),
        blurRadius: 20,
        spreadRadius: 2,
      ),
    ],
  );

  static const BoxDecoration avatarPlaceholderDecoration = BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
      colors: [Color(0xFF1A7A52), Color(0xFF0E5C38)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const LinearGradient badgeGradient = LinearGradient(
    colors: [Color(0xFF1BB871), Color(0xFF08683F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const BoxDecoration editBadgeDecoration = BoxDecoration(
    gradient: badgeGradient,
    shape: BoxShape.circle,
    border: Border.fromBorderSide(
      BorderSide(color: Colors.white, width: editBadgeBorderWidth),
    ),
  );

  static const BoxDecoration verifiedBadgeDecoration = BoxDecoration(
    gradient: badgeGradient,
    shape: BoxShape.circle,
    border: Border.fromBorderSide(
      BorderSide(color: Colors.white, width: verifiedBadgeBorderWidth),
    ),
  );
}
