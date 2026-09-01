import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/responsive_asset_image.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/home_product_card_details.dart';

class HomeProductCard extends StatelessWidget {
  const HomeProductCard({
    required this.product,
    required this.onTap,
    super.key,
  });
  final HomeProduct product;
  final VoidCallback onTap;
  static const imageHeight = 154.0;

  static double heightForWidth(double width) {
    // Price and two metadata rows need the full details height even on compact
    // screens. Keeping this consistent also prevents sale cards from clipping.
    return imageHeight + 98;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final titleSize = width < 380 ? 13.0 : 15.0;
    final detailsHeight =
        HomeProductCard.heightForWidth(width) - HomeProductCard.imageHeight;
    final borderRadius = BorderRadius.circular(13);

    return Semantics(
      container: true,
      explicitChildNodes: true,
      button: true,
      label:
          'View details for ${product.name}. '
          '${product.hasSale ? 'On sale for ${product.activePrice} ${product.unit}. ' : ''}'
          '${product.freshnessLabel == null ? '' : '${product.freshnessLabel}. '}'
          '${product.availableQuantityLabel}',
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              boxShadow: [
                BoxShadow(
                  color: AgrisellColors.brandBlack.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: borderRadius,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: HomeProductCard.imageHeight,
                    child: ColoredBox(
                      color: AgrisellColors.searchBackground,
                      child: Hero(
                        tag: 'home-product-${product.id}',
                        transitionOnUserGestures: true,
                        child: ResponsiveAssetImage(
                          asset: product.image,
                          imageUrl: product.imageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          semanticLabel: '${product.name} product photo',
                          filterQuality: FilterQuality.medium,
                          gaplessPlayback: true,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: detailsHeight,
                    child: HomeProductCardDetails(
                      product: product,
                      titleSize: titleSize,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
