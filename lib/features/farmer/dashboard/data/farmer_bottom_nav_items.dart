import 'package:flutter/material.dart';

import 'package:agresell_app/core/constants/agrisell_assets.dart';
import 'package:agresell_app/core/models/home_bottom_nav_item.dart';

const farmerBottomNavItems = [
  HomeBottomNavItem(
    label: 'Products',
    iconData: Icons.inventory_2_outlined,
    activeIconData: Icons.inventory_2_rounded,
  ),
  HomeBottomNavItem(
    label: 'Messages',
    iconData: Icons.sms_outlined,
    activeIconData: Icons.sms_rounded,
  ),
  HomeBottomNavItem(
    label: 'Reserve',
    icon: AgrisellAssets.iconReserve,
    activeIcon: AgrisellAssets.iconReserveActive,
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
