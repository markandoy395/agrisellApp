import 'package:flutter/material.dart';

import 'package:agresell_app/core/models/home_bottom_nav_item.dart';

const riderBottomNavItems = [
  HomeBottomNavItem(
    label: 'Home',
    iconData: Icons.home_outlined,
    activeIconData: Icons.home_rounded,
  ),
  HomeBottomNavItem(
    label: 'Deliveries',
    iconData: Icons.delivery_dining_outlined,
    activeIconData: Icons.delivery_dining_rounded,
  ),
  HomeBottomNavItem(
    label: 'Map',
    iconData: Icons.map_outlined,
    activeIconData: Icons.map_rounded,
  ),
  HomeBottomNavItem(
    label: 'Messages',
    iconData: Icons.chat_bubble_outline_rounded,
    activeIconData: Icons.chat_bubble_rounded,
  ),
  HomeBottomNavItem(
    label: 'Profile',
    iconData: Icons.account_circle_outlined,
    activeIconData: Icons.account_circle_rounded,
  ),
];
