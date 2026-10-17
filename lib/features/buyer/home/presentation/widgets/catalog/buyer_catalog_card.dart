import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/widgets/responsive_asset_image.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import '../../styles/buyer_catalog_styles.dart';
import 'buyer_catalog_icon.dart';
import 'buyer_catalog_price.dart';

class BuyerCatalogCard extends StatelessWidget {
  const BuyerCatalogCard({
    required this.product,
    required this.onTap,
    required this.onAdd,
    this.onSave,
    this.saved = false,
    this.sale = false,
    super.key,
  });
  final HomeProduct product;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback? onSave;
  final bool saved;
  final bool sale;

  @override
  Widget build(BuildContext context) {
    final discount = sale ? catalogDiscount(product) : null;
    return Material(
      color: AgrisellColors.surface,
      borderRadius: BuyerCatalogStyles.radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: sale ? 1.07 : 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BuyerCatalogStyles.imageRadius,
                      child: ColoredBox(
                        color: BuyerCatalogStyles.imageFill,
                        child: ResponsiveAssetImage(
                          asset: product.image,
                          imageUrl: product.imageUrl,
                          fit: BoxFit.cover,
                          semanticLabel: '${product.name} product photo',
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        tooltip: saved
                            ? 'Unsave ${product.name}'
                            : 'Save ${product.name}',
                        onPressed: onSave,
                        isSelected: saved,
                        icon: const BuyerCatalogIcon('heart', size: 16),
                        selectedIcon: const Icon(
                          Icons.favorite_rounded,
                          color: AgrisellColors.authGreen,
                          size: 18,
                        ),
                      ),
                    ),
                    if (discount != null)
                      Positioned(
                        left: 4,
                        bottom: 2,
                        child: DecoratedBox(
                          decoration: BuyerCatalogStyles.discount,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            child: Text(
                              '-$discount%',
                              style: BuyerCatalogStyles.discountText,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: BuyerCatalogStyles.name,
              ),
              const SizedBox(height: 3),
              BuyerCatalogPrice(product: product, sale: sale),
              const Spacer(),
              Row(
                children: [
                  const BuyerCatalogIcon('stock', size: 14),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      product.availableQuantityValue,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: BuyerCatalogStyles.stock,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Add ${product.name} to basket',
                    onPressed: product.canOrder ? onAdd : null,
                    style: BuyerCatalogStyles.cartButton,
                    icon: const BuyerCatalogIcon('cart'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
