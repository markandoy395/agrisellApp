import 'package:flutter/material.dart';

import 'package:agresell_app/core/constants/agrisell_routes.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/home/presentation/styles/home_header_styles.dart';

class HomeQuickAccessSheet extends StatelessWidget {
  const HomeQuickAccessSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const HomeQuickAccessSheet(),
    );
  }

  void _openRoute(BuildContext context, String route) {
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: HomeHeaderStyles.sheetMargin,
        child: Material(
          color: AgrisellColors.surface,
          borderRadius: HomeHeaderStyles.sheetBorderRadius,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: HomeHeaderStyles.sheetPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: HomeHeaderStyles.handleWidth,
                  height: HomeHeaderStyles.handleHeight,
                  decoration: HomeHeaderStyles.handleDecoration,
                ),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Quick access',
                      style: HomeHeaderStyles.quickAccessTitleStyle,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                HomeQuickActionTile(
                  icon: Icons.shopping_basket_outlined,
                  title: 'My basket',
                  subtitle: 'Review produce ready for checkout',
                  onTap: () => _openRoute(context, AgrisellRoutes.basket),
                ),
                HomeQuickActionTile(
                  icon: Icons.local_shipping_outlined,
                  title: 'My orders',
                  subtitle: 'Track shipping and delivery updates',
                  onTap: () => _openRoute(context, AgrisellRoutes.buyerOrders),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeQuickActionTile extends StatelessWidget {
  const HomeQuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: HomeHeaderStyles.tileShape,
      leading: Container(
        width: HomeHeaderStyles.tileLeadingSize,
        height: HomeHeaderStyles.tileLeadingSize,
        decoration: HomeHeaderStyles.tileLeadingDecoration,
        child: Icon(
          icon,
          color: AgrisellColors.authGreen,
          size: HomeHeaderStyles.tileIconSize,
        ),
      ),
      title: Text(title, style: HomeHeaderStyles.tileTitleStyle),
      subtitle: Text(subtitle, style: HomeHeaderStyles.tileSubtitleStyle),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: HomeHeaderStyles.chevronSize,
      ),
    );
  }
}
