import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/home_product_card.dart';

class HomeSaleProductsSection extends StatelessWidget {
  const HomeSaleProductsSection({
    required this.products,
    required this.onViewAll,
    required this.onProductTap,
    super.key,
  });

  static const previewLimit = 8;

  final List<HomeProduct> products;
  final VoidCallback onViewAll;
  final ValueChanged<HomeProduct> onProductTap;

  @override
  Widget build(BuildContext context) {
    final preview = products.take(previewLimit).toList(growable: false);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = screenWidth < 380 ? 166.0 : 178.0;
    final cardHeight = HomeProductCard.heightForWidth(screenWidth);

    return Semantics(
      container: true,
      label: '${products.length} sale products',
      child: Column(
        key: const ValueKey('home-sale-products-section'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sale products',
                        style: SharedPresentationStyles.headingTitleExtraBold,
                      ),
                      Text(
                        'Limited-time prices selected for you',
                        style: SharedPresentationStyles.mutedCaptionMedium,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  key: const ValueKey('home-sale-products-view-all'),
                  onPressed: onViewAll,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('View All'),
                      SizedBox(width: 2),
                      Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: cardHeight,
            child: ListView.separated(
              key: const ValueKey('home-sale-products-list'),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: preview.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = preview[index];
                return SizedBox(
                  width: cardWidth,
                  child: HomeProductCard(
                    product: product,
                    onTap: () => onProductTap(product),
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
