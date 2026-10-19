import 'package:flutter/material.dart';

import '../widgets/buyer_profile_style.dart';

/// Predefined styling tokens and variants for the buyer settings panel.
abstract final class BuyerSettingsPanelStyles {
  // Surface
  static const panelBackground = BuyerProfileStyle.background;
  static const panelBorderRadius = BorderRadius.vertical(
    top: Radius.circular(26),
  );

  // Drag handle
  static const dragHandleWidth = 38.0;
  static const dragHandleHeight = 4.5;
  static const dragHandleSpacingTop = SizedBox(height: 10);
  static const dragHandleSpacingBottom = SizedBox(height: 14);
  static final dragHandleDecoration = BoxDecoration(
    color: const Color(0xFFCFDAD6),
    borderRadius: BorderRadius.circular(4),
  );

  // Header
  static const headerPadding = EdgeInsets.fromLTRB(20, 0, 16, 12);
  static const headerTitleStyle = TextStyle(
    fontFamily: 'Poppins',
    color: BuyerProfileStyle.ink,
    fontSize: 15,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );
  static const closeButtonSize = 40.0;
  static const closeIconSize = 22.0;
  static const closeIconColor = BuyerProfileStyle.green;
  static final closeButtonRadius = BorderRadius.circular(12);
  static final closeButtonDecoration = BoxDecoration(
    color: BuyerProfileStyle.mint,
    borderRadius: closeButtonRadius,
    border: Border.all(color: BuyerProfileStyle.borderSubtle, width: 1),
  );

  // Identity hero card
  static const identityMargin = EdgeInsets.symmetric(horizontal: 20);
  static const identityPadding = EdgeInsets.all(16);
  static const identityGradient = LinearGradient(
    colors: [Color(0xFF062E1D), Color(0xFF0B5435), Color(0xFF0E6B43)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.55, 1.0],
  );
  static final identityRadius = BorderRadius.circular(16);
  static final identityCardDecoration = BoxDecoration(
    gradient: identityGradient,
    borderRadius: identityRadius,
  );
  static const avatarSize = 46.0;
  static const avatarIconSize = 28.0;
  static const avatarIconColor = Color(0xFFB8F0D6);
  static final avatarDecoration = BoxDecoration(
    color: Colors.white.withValues(alpha: 0.15),
    shape: BoxShape.circle,
    border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 2),
  );
  static const identityTextSpacing = SizedBox(width: 14);
  static const identityNameStyle = TextStyle(
    fontFamily: 'Poppins',
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );
  static const identityEmailSpacing = SizedBox(height: 2);
  static final identityEmailStyle = TextStyle(
    fontFamily: 'Poppins',
    color: Colors.white.withValues(alpha: 0.65),
    fontSize: 13,
  );

  // List layout
  static const spacingIdentityToList = SizedBox(height: 6);
  static const listPadding = EdgeInsets.fromLTRB(20, 0, 20, 8);

  // Group container
  static const groupPadding = EdgeInsets.only(top: 18);
  static const groupLabelPadding = EdgeInsets.only(left: 4, bottom: 8);
  static const groupLabelStyle = BuyerProfileStyle.sectionLabel;
  static final groupRadius = BorderRadius.circular(16);
  static final groupDecoration = BoxDecoration(
    color: BuyerProfileStyle.surface,
    borderRadius: groupRadius,
    border: Border.all(color: BuyerProfileStyle.borderSubtle, width: 1),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF08683F).withValues(alpha: 0.05),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
  static const groupDivider = Divider(
    height: 1,
    indent: 58,
    endIndent: 0,
    color: Color(0xFFEEF3F0),
  );

  // Action tile
  static const tilePadding = EdgeInsets.symmetric(horizontal: 14, vertical: 12);
  static const tileSpacing = SizedBox(width: 12);
  static const chevronSpacing = SizedBox(width: 6);
  static const chevronSize = 20.0;
  static const chevronColor = Color(0xFFA0B8AF);
  static const destructiveChevronColor = Color(0xFFD63031);

  static const iconBoxSize = 40.0;
  static const iconSize = 20.0;
  static const iconColor = BuyerProfileStyle.green;
  static const destructiveIconColor = Color(0xFFD63031);
  static final iconRadius = BorderRadius.circular(11);

  static final iconDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFFE8F5EE), Color(0xFFD1EDDF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: iconRadius,
    border: Border.all(color: BuyerProfileStyle.borderSubtle, width: 1),
  );

  static final destructiveIconDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFFFFF0F0), Color(0xFFFFE4E4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: iconRadius,
    border: Border.all(color: const Color(0xFFFFCCCC), width: 1),
  );

  static final titleStyle = BuyerProfileStyle.tileTitle.copyWith(
    color: BuyerProfileStyle.ink,
  );

  static final destructiveTitleStyle = BuyerProfileStyle.tileTitle.copyWith(
    color: const Color(0xFFD63031),
  );

  static const subtitleStyle = BuyerProfileStyle.tileSubtitle;
  static const subtitleSpacing = SizedBox(height: 2);

  // Predefined style variants
  static BoxDecoration tileIconDecoration({required bool destructive}) =>
      destructive ? destructiveIconDecoration : iconDecoration;

  static Color tileIconColor({required bool destructive}) =>
      destructive ? destructiveIconColor : iconColor;

  static TextStyle tileTitleStyle({required bool destructive}) =>
      destructive ? destructiveTitleStyle : titleStyle;

  static Color tileChevronColor({required bool destructive}) =>
      destructive ? destructiveChevronColor : chevronColor;
}
