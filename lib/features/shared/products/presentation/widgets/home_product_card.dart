import 'package:agresell_app/features/shared/products/presentation/styles/home_product_card_styles.dart';
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
  static const imageHeight = 118.0;

  static double heightForWidth(double width) => imageHeight + 90;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final detailsHeight =
        HomeProductCard.heightForWidth(width) - HomeProductCard.imageHeight;
    final borderRadius = BorderRadius.circular(10);

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
            decoration: HomeProductCardStyles.decoratedBoxDecoration(
              borderRadius,
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
                    child: HomeProductCardDetails(product: product),
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
