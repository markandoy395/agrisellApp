import 'package:flutter/material.dart';
import 'package:agresell_app/features/shared/widgets/navigation/custom_bottom_nav_bar.dart';
import '../../styles/home_screen_styles.dart';
import '../../../data/home_bottom_nav_items.dart';

class BuyerCatalogBottomNav extends StatelessWidget {
  const BuyerCatalogBottomNav({required this.badgeCounts, super.key});
  final Map<int, int> badgeCounts;

  @override
  Widget build(BuildContext context) => CustomBottomNavBar(
    selectedIndex: 0,
    items: homeBottomNavItems,
    badgeCounts: badgeCounts,
    background: HomeScreenStyles.navBarBackground,
    activeBackground: HomeScreenStyles.navBarActiveBackground,
    activeIconColor: HomeScreenStyles.navBarActiveIconColor,
    inactiveIconColor: HomeScreenStyles.navBarInactiveIconColor,
    inactiveLabelColor: HomeScreenStyles.navBarInactiveLabelColor,
    shadowColor: HomeScreenStyles.navBarShadowColor,
    onItemSelected: (index) => Navigator.pop(context, index),
  );
}
