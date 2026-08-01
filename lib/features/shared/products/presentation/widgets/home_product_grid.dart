import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/home_product_card.dart';

class HomeProductGrid extends StatelessWidget {
  const HomeProductGrid({
    required this.onProductTap,
    required this.products,
    this.isSaved,
    this.onSavedToggle,
    this.onAddToBasket,
    super.key,
  });

  final List<HomeProduct> products;
  final bool Function(String productId)? isSaved;
  final ValueChanged<HomeProduct>? onSavedToggle;
  final ValueChanged<HomeProduct>? onAddToBasket;
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
          product: product,
          isSaved: isSaved?.call(product.id) ?? false,
          onSavedToggle: onSavedToggle == null
              ? null
              : () => onSavedToggle!(product),
          onAddToBasket: onAddToBasket == null
              ? null
              : () => onAddToBasket!(product),
          onTap: () => onProductTap(product),
        );
      },
    );
  }
}
