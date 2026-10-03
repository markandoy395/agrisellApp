import 'package:flutter/material.dart';

import 'package:agresell_app/core/constants/agrisell_assets.dart';
import 'package:agresell_app/core/constants/agrisell_routes.dart';
import 'package:agresell_app/core/widgets/responsive_asset_image.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/buyer/cart/presentation/widgets/common/basket_count_icon_button.dart';
import 'package:agresell_app/features/buyer/home/presentation/styles/home_header_styles.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_quick_access_sheet.dart';
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
          onTap: () => HomeQuickAccessSheet.show(context),
        ),
      ],
    );

    final padding = horizontalPadding;
    if (padding != null) {
      return Padding(
        padding: HomeHeaderStyles.headerPadding(padding),
        child: content,
      );
    }

    return content;
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
