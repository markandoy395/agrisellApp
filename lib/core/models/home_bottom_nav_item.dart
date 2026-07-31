import 'package:flutter/material.dart';

class HomeBottomNavItem {
  const HomeBottomNavItem({
    required this.label,
    this.icon,
    this.activeIcon,
    this.iconData,
    this.activeIconData,
  }) : assert(icon != null || iconData != null),
       assert(activeIcon != null || activeIconData != null);

  final String label;
  final String? icon;
  final String? activeIcon;
  final IconData? iconData;
  final IconData? activeIconData;
}
