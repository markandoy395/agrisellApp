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
    iconData: Icons.local_shipping_outlined,
    activeIconData: Icons.local_shipping_rounded,
  ),
  HomeBottomNavItem(
    label: 'Map',
    iconData: Icons.map_outlined,
    activeIconData: Icons.map_rounded,
  ),
  HomeBottomNavItem(
    label: 'Messages',
    iconData: Icons.sms_outlined,
    activeIconData: Icons.sms_rounded,
  ),
  HomeBottomNavItem(
    label: 'Profile',
    iconData: Icons.person_outline_rounded,
    activeIconData: Icons.person_rounded,
  ),
];
