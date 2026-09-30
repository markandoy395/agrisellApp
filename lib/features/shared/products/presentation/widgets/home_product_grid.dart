import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/home_product_card.dart';

class HomeProductGrid extends StatelessWidget {
  const HomeProductGrid({
    required this.onProductTap,
    required this.products,
    super.key,
  });

  final List<HomeProduct> products;
  final ValueChanged<HomeProduct> onProductTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return SliverGrid.builder(
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: width < 380 ? 10 : 12,
        mainAxisSpacing: width < 380 ? 12 : 14,
        mainAxisExtent: HomeProductCard.heightForWidth(width),
      ),
      itemBuilder: (context, index) {
        final product = products[index];

        return HomeProductCard(
          key: ValueKey('home-product-${product.id}'),
          product: product,
          onTap: () => onProductTap(product),
        );
      },
    );
  }
}
