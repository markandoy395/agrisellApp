import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/buyer/cart/presentation/styles/basket_suggestions_styles.dart';
import 'package:agresell_app/features/buyer/home/presentation/screens/product_detail_screen.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/presentation/controllers/home_product_catalog_controller.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/product_thumbnail.dart';

class BasketSuggestionCard extends StatelessWidget {
  const BasketSuggestionCard({
    required this.product,
    required this.catalogController,
    super.key,
  });

  final HomeProduct product;
  final HomeProductCatalogController catalogController;

  @override
  Widget build(BuildContext context) {
    final canAddToBasket = product.canOrder;

    return Semantics(
      button: true,
      label: 'View ${product.name}',
      child: Material(
        color: BasketSuggestionsStyles.cardBackground,
        borderRadius: BasketSuggestionsStyles.cardRadius,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BasketSuggestionsStyles.cardRadius,
          onTap: () {
            Navigator.of(context).push(
              agrisellMaterialPageRoute<void>(
                builder: (_) => ProductDetailScreen(
                  product: product,
                  catalogController: catalogController,
                ),
              ),
            );
          },
          child: Ink(
            decoration: BasketSuggestionsStyles.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: BasketSuggestionsStyles.thumbnailHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(
                        color: AgrisellColors.searchBackground,
                        child: ProductThumbnail(
                          asset: product.image,
                          imageUrl: product.imageUrl,
                          width: double.infinity,
                          height: BasketSuggestionsStyles.thumbnailHeight,
                          borderRadius: 0,
                          semanticLabel: '${product.name} product photo',
                          filterQuality: FilterQuality.medium,
                          gaplessPlayback: true,
                        ),
                      ),
                      Positioned(
                        top: BasketSuggestionsStyles.actionButtonPosition.top,
                        right:
                            BasketSuggestionsStyles.actionButtonPosition.right,
                        child: Material(
                          color: BasketSuggestionsStyles.actionButtonBackground,
                          shape: const CircleBorder(),
                          elevation: 1,
                          child: IconButton(
                            tooltip: canAddToBasket
                                ? 'Add ${product.name} to basket'
                                : 'Product unavailable',
                            constraints: const BoxConstraints.tightFor(
                              width: BasketSuggestionsStyles.cartActionSize,
                              height: BasketSuggestionsStyles.cartActionSize,
                            ),
                            padding: EdgeInsets.zero,
                            onPressed: canAddToBasket
                                ? () => _addToBasket(context)
                                : null,
                            icon: Icon(
                              canAddToBasket
                                  ? Icons.add_shopping_cart_rounded
                                  : Icons.block_rounded,
                              size: BasketSuggestionsStyles.cartActionIconSize,
                              color: canAddToBasket
                                  ? BasketSuggestionsStyles.iconColor
                                  : BasketSuggestionsStyles.mutedIconColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: BasketSuggestionsStyles.cardContentPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: BasketSuggestionsStyles.productTitle,
                        ),
                        const SizedBox(
                          height: BasketSuggestionsStyles.cardTitleToSellerGap,
                        ),
                        Text(
                          product.sellerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: BasketSuggestionsStyles.sellerName,
                        ),
                        const Spacer(),
                        Text(
                          '${product.price} ${product.unit}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: BasketSuggestionsStyles.productPrice,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addToBasket(BuildContext context) {
    BasketController.instance.addProduct(product);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showAppSnackBar(
        BasketSuggestionsStyles.snackBar(
          '${product.name} added to your basket.',
        ),
      );
  }
}
