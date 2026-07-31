import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/core/widgets/responsiveAssetImage.dart';
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

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(13);
    final label = product.isAvailable
        ? 'View ${product.name}. ${product.availableQuantityLabel}'
        : '${product.name} is sold. ${product.availableQuantityLabel}';

    return Semantics(
      button: product.isAvailable,
      enabled: product.isAvailable,
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: AgrisellColors.brandBlack.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
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
            decodeWidth: 1200,
          ),
        ),
        Positioned(
          left: 10,
          bottom: 10,
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
      height: 108,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(13, 9, 13, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, color: valueColor, size: 18),
              ],
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
            Text(
              product.availableQuantityLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: valueColor,
                fontSize: 12,
                height: 1,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  color: AgrisellColors.mutedText,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Harvest date · ${product.harvestDate}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AgrisellColors.mutedText,
                      fontSize: 12,
                      height: 1,
                      fontWeight: FontWeight.w600,
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
