import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/widgets/responsive_asset_image.dart';
import 'package:agresell_app/features/buyer/home/presentation/styles/farmer_product_card_styles.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer_shop/farmer_product_card_details.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer_shop/sold_overlay.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/product_sale_status_badge.dart';

class FarmerProductCard extends StatelessWidget {
  const FarmerProductCard({
    required this.product,
    required this.onTap,
    super.key,
  });

  final HomeProduct product;
  final VoidCallback? onTap;
  static const cardHeight = FarmerProductCardStyles.cardHeight;

  @override
  Widget build(BuildContext context) {
    final label = product.isAvailable
        ? 'View ${product.name}. ${product.availableQuantityLabel}'
        : '${product.name} is sold. ${product.availableQuantityLabel}';

    return Semantics(
      button: product.isAvailable,
      enabled: product.isAvailable,
      label: label,
      child: DecoratedBox(
        decoration: FarmerProductCardStyles.cardDecoration,
        child: ClipRRect(
          borderRadius: FarmerProductCardStyles.cardBorderRadius,
          child: Material(
            color: AgrisellColors.surface,
            child: InkWell(
              onTap: product.isAvailable ? onTap : null,
              child: Column(
                children: [
                  Expanded(child: _ProductImage(product: product)),
                  FarmerProductCardDetails(product: product),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product});

  final HomeProduct product;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Hero(
          tag: 'home-product-${product.id}',
          transitionOnUserGestures: true,
          child: ResponsiveAssetImage(
            asset: product.image,
            imageUrl: product.imageUrl,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            semanticLabel: '${product.name} product photo',
            filterQuality: FilterQuality.medium,
            gaplessPlayback: true,
          ),
        ),
        Positioned(
          left: 8,
          bottom: 8,
          child: ProductSaleStatusBadge(product: product, iconOnly: true),
        ),
        if (!product.isAvailable) const SoldOverlay(),
      ],
    );
  }
}
