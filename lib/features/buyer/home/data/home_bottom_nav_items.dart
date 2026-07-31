import 'package:flutter/material.dart';

import 'package:agresell_app/core/constants/agrisellAssets.dart';
import 'package:agresell_app/core/models/home_bottom_nav_item.dart';

const homeBottomNavItems = [
  HomeBottomNavItem(
    label: 'Home',
    icon: AgrisellAssets.iconHome,
    activeIcon: AgrisellAssets.iconHomeActive,
  ),
  HomeBottomNavItem(
    label: 'Messages',
    iconData: Icons.sms_outlined,
    activeIconData: Icons.sms_rounded,
  ),
  HomeBottomNavItem(
    label: 'Farmers',
    icon: AgrisellAssets.iconFarmers,
    activeIcon: AgrisellAssets.iconFarmersActive,
  ),
  HomeBottomNavItem(
    label: 'Alerts',
    icon: AgrisellAssets.iconNotifications,
    activeIcon: AgrisellAssets.iconNotificationsActive,
  ),
  HomeBottomNavItem(
    label: 'Account',
    icon: AgrisellAssets.iconMe,
    activeIcon: AgrisellAssets.iconMeActive,
  ),
];
