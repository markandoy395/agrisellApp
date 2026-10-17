import 'package:flutter/material.dart';

import 'package:agresell_app/core/models/home_bottom_nav_item.dart';

const farmerBottomNavItems = [
  HomeBottomNavItem(
    label: 'Products',
    iconData: Icons.inventory_2_outlined,
    activeIconData: Icons.inventory_2_rounded,
  ),
  HomeBottomNavItem(
    label: 'Messages',
    iconData: Icons.chat_bubble_outline_rounded,
    activeIconData: Icons.chat_bubble_rounded,
  ),
  HomeBottomNavItem(
    label: 'Reserve',
    iconData: Icons.event_available_outlined,
    activeIconData: Icons.event_available_rounded,
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
