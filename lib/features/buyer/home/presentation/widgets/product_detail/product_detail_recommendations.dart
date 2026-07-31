import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/core/widgets/responsiveAssetImage.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';

class ProductDetailRecommendations extends StatelessWidget {
  const ProductDetailRecommendations({
    required this.products,
    required this.onProductSelected,
    super.key,
  });

  final List<HomeProduct> products;
  final ValueChanged<HomeProduct> onProductSelected;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    final cardWidth = (MediaQuery.sizeOf(context).width - 50).clamp(
      270.0,
      340.0,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              'Recommended for you',
              style: TextStyle(
                color: AgrisellColors.headingGreen,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final product = products[index];
                return SizedBox(
                  width: cardWidth,
                  child: _RecommendationCard(
                    product: product,
                    onTap: () => onProductSelected(product),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.product, required this.onTap});

  final HomeProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);

    return Semantics(
      button: true,
      label: 'View ${product.name}',
      child: Material(
        color: AgrisellColors.surface,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: AgrisellColors.borderLine),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ResponsiveAssetImage(
                    asset: product.image,
                    imageUrl: product.imageUrl,
                    width: 78,
                    height: 82,
                    fit: BoxFit.cover,
                    semanticLabel: '${product.name} product photo',
                    gaplessPlayback: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AgrisellColors.headingGreen,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AgrisellColors.forestSoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Available',
                          style: TextStyle(
                            color: AgrisellColors.authGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '${product.price} ${product.unit}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AgrisellColors.authGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AgrisellColors.authGreen,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
