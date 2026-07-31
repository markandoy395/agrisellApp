import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/core/widgets/responsiveAssetImage.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';

class ProductImageHeader extends StatelessWidget {
  const ProductImageHeader({
    required this.product,
    required this.height,
    super.key,
  });

  final HomeProduct product;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
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
              decodeWidth: 1200,
            ),
          ),
        ),
      ),
    );
  }
}
