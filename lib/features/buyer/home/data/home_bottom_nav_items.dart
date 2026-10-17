import 'package:flutter/material.dart';

import 'package:agresell_app/core/models/home_bottom_nav_item.dart';

const homeBottomNavItems = [
  HomeBottomNavItem(
    label: 'Home',
    iconData: Icons.home_outlined,
    activeIconData: Icons.home_rounded,
  ),
  HomeBottomNavItem(
    label: 'Messages',
    iconData: Icons.chat_bubble_outline_rounded,
    activeIconData: Icons.chat_bubble_rounded,
  ),
  HomeBottomNavItem(
    label: 'Farmers',
    iconData: Icons.storefront_outlined,
    activeIconData: Icons.storefront_rounded,
  ),
  HomeBottomNavItem(
    label: 'Alerts',
    iconData: Icons.notifications_none_rounded,
    activeIconData: Icons.notifications_rounded,
  ),
  HomeBottomNavItem(
    label: 'Account',
    iconData: Icons.account_circle_outlined,
    activeIconData: Icons.account_circle_rounded,
  ),
];
