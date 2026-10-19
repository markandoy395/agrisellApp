import 'package:flutter/material.dart';

import '../widgets/farmer_profile_style.dart';

abstract final class FarmerProfileScreenStyles {
  static const background = FarmerProfileStyle.background;
  static const transparent = Colors.transparent;
  static final settingsBarrier = const Color(
    0xFF164A38,
  ).withValues(alpha: 0.18);
  static const initialSettingsSize = 0.79;
  static const minSettingsSize = 0.45;
  static const maxSettingsSize = 0.95;
  static EdgeInsets contentPadding(BuildContext context) {
    final horizontal = MediaQuery.sizeOf(context).width < 380 ? 12.0 : 16.0;
    return EdgeInsets.fromLTRB(
      horizontal,
      16,
      horizontal,
      8 + MediaQuery.paddingOf(context).bottom,
    );
  }

  static const verificationMargin = EdgeInsets.only(bottom: 14);
  static const sectionPadding = EdgeInsets.only(left: 4);
  static const tilePadding = EdgeInsets.symmetric(horizontal: 16, vertical: 14);
  static const tileRadius = BorderRadius.all(Radius.circular(18));
  static const divider = Color(0xFFEEF3F0);
  static const sessionDivider = Color(0xFFEFF3F4);
  static const sectionLabel = FarmerProfileStyle.sectionLabel;
  static const subtitle = FarmerProfileStyle.tileSubtitle;
  static const destructiveColor = Color(0xFFD63031);
  static const iconColor = FarmerProfileStyle.green;
  static const chevronColor = Color(0xFFA0B8AF);
  static final tileTitle = FarmerProfileStyle.tileTitle.copyWith(
    color: FarmerProfileStyle.ink,
  );
  static final destructiveTileTitle = FarmerProfileStyle.tileTitle.copyWith(
    color: destructiveColor,
  );
  static const _iconRadius = BorderRadius.all(Radius.circular(12));
  static const tileIcon = BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFFE8F5EE), Color(0xFFD1EDDF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: _iconRadius,
    border: Border.fromBorderSide(
      BorderSide(color: FarmerProfileStyle.borderSubtle),
    ),
  );
  static const destructiveTileIcon = BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFFFFF0F0), Color(0xFFFFE4E4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: _iconRadius,
    border: Border.fromBorderSide(BorderSide(color: Color(0xFFFFCCCC))),
  );
}
