import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/widgets/responsive_asset_image.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/product_sale_status_badge.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer_shop/sold_overlay.dart';

class FarmerProductCard extends StatelessWidget {
  const FarmerProductCard({
    required this.product,
    required this.onTap,
    super.key,
  });

  final HomeProduct product;
  final VoidCallback? onTap;
  static const cardHeight = 208.0;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10);
    final label = product.isAvailable
        ? 'View ${product.name}. ${product.availableQuantityLabel}'
        : '${product.name} is sold. ${product.availableQuantityLabel}';

    return Semantics(
      button: product.isAvailable,
      enabled: product.isAvailable,
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AgrisellColors.surface,
          borderRadius: radius,
          border: Border.all(color: AgrisellColors.borderLine),
          boxShadow: [
            BoxShadow(
              color: AgrisellColors.brandBlack.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Material(
            color: AgrisellColors.surface,
            child: InkWell(
              onTap: product.isAvailable ? onTap : null,
              child: Column(
                children: [
                  Expanded(child: _ProductImage(product: product)),
                  _ProductDetails(product: product),
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

class _ProductDetails extends StatelessWidget {
  const _ProductDetails({required this.product});

  final HomeProduct product;

  @override
  Widget build(BuildContext context) {
    final textColor = product.isAvailable
        ? AgrisellColors.brandBlack
        : AgrisellColors.brandBlack.withValues(alpha: 0.64);
    final valueColor = product.isAvailable
        ? AgrisellColors.authGreen
        : AgrisellColors.mutedText;

    return SizedBox(
      height: 90,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                height: 1.1,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                text: product.price,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 15,
                  height: 1,
                  fontWeight: FontWeight.w800,
                ),
                children: [
                  TextSpan(
                    text: ' ${product.unit}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            _FarmerProductMeta(
              icon: Icons.inventory_2_outlined,
              value: product.availableQuantityLabel,
              color: valueColor,
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: AgrisellColors.mutedText,
                  size: 14,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    product.freshnessLabel ?? product.harvestDate,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AgrisellColors.mutedText,
                      fontSize: 12,
                      height: 1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FarmerProductMeta extends StatelessWidget {
  const _FarmerProductMeta({
    required this.icon,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: color, size: 14),
      const SizedBox(width: 5),
      Expanded(
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 12,
            height: 1,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}
