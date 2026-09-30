import 'package:flutter/material.dart';

import 'package:agresell_app/core/constants/agrisell_assets.dart';
import 'package:agresell_app/core/constants/agrisell_routes.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/widgets/responsive_asset_image.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/buyer/cart/presentation/widgets/common/basket_count_icon_button.dart';
import 'package:agresell_app/features/shared/widgets/navigation/home_asset_icon.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    this.horizontalPadding,
    super.key,
  });

  final double? horizontalPadding;

  @override
  Widget build(BuildContext context) {
    Widget content = Row(
      children: [
        const ResponsiveAssetImage(
          asset: AgrisellAssets.logoLandscapeTextOnly,
          height: 38,
          fit: BoxFit.contain,
          semanticLabel: 'AgriSell',
        ),
        const Spacer(),
        AnimatedBuilder(
          animation: BasketController.instance,
          builder: (context, _) {
            final controller = BasketController.instance;
            return BasketCountIconButton(
              count: controller.totalQuantity,
              pulse: controller.pulse,
              onTap: () =>
                  Navigator.of(context).pushNamed(AgrisellRoutes.basket),
            );
          },
        ),
        const SizedBox(width: 14),
        _HeaderIconButton(
          semanticLabel: 'Menu',
          iconAsset: AgrisellAssets.iconMenu,
          onTap: () => _showQuickMenu(context),
        ),
      ],
    );

    if (horizontalPadding != null) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding!,
          14,
          horizontalPadding!,
          12,
        ),
        child: content,
      );
    }

    return content;
  }

  void _showQuickMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Material(
              color: AgrisellColors.surface,
              borderRadius: BorderRadius.circular(20),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AgrisellColors.mutedText.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'Quick access',
                          style: TextStyle(
                            color: AgrisellColors.headingGreen,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _QuickActionTile(
                      icon: Icons.shopping_basket_outlined,
                      title: 'My basket',
                      subtitle: 'Review produce ready for checkout',
                      onTap: () => _openRoute(
                        context,
                        sheetContext,
                        AgrisellRoutes.basket,
                      ),
                    ),
                    _QuickActionTile(
                      icon: Icons.local_shipping_outlined,
                      title: 'My orders',
                      subtitle: 'Track shipping and delivery updates',
                      onTap: () => _openRoute(
                        context,
                        sheetContext,
                        AgrisellRoutes.buyerOrders,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openRoute(
    BuildContext context,
    BuildContext sheetContext,
    String route,
  ) {
    Navigator.of(sheetContext).pop();
    Navigator.of(context).pushNamed(route);
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          color: AgrisellColors.forestSoft,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AgrisellColors.authGreen, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AgrisellColors.brandBlack,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AgrisellColors.mutedText, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.semanticLabel,
    required this.iconAsset,
    required this.onTap,
  });

  final String semanticLabel;
  final String iconAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkResponse(
        onTap: onTap,
        radius: 28,
        child: HomeAssetIcon(asset: iconAsset, size: 38),
      ),
    );
  }
}
