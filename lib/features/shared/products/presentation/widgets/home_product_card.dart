import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/responsiveAssetImage.dart';
import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/home_product_card_actions.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/home_product_card_details.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/product_sale_status_badge.dart';

class HomeProductCard extends StatelessWidget {
  const HomeProductCard({
    required this.product,
    required this.onTap,
    this.isSaved = false,
    this.onSavedToggle,
    this.onAddToBasket,
    super.key,
  });
  final HomeProduct product;
  final VoidCallback onTap;
  final bool isSaved;
  final VoidCallback? onSavedToggle;
  final VoidCallback? onAddToBasket;
  static const imageHeight = 154.0;

  static double heightForWidth(double width) {
    return imageHeight + (width < 380 ? 90 : 98);
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
          'View details for ${product.name}. ${product.availableQuantityLabel}',
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
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ColoredBox(
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
                              decodeWidth: 1200,
                            ),
                          ),
                        ),
                        HomeProductCardActions(
                          productName: product.name,
                          isAvailable: product.canOrder,
                          isSaved: isSaved,
                          onSavedToggle: onSavedToggle,
                          onAddToBasket: onAddToBasket,
                        ),
                        Positioned(
                          left: 8,
                          top: 8,
                          child: ProductSaleStatusBadge(
                            product: product,
                            iconOnly: true,
                          ),
                        ),
                      ],
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
