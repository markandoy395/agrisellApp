import 'package:agresell_app/features/buyer/home/presentation/styles/product_detail_price_line_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/products/domain/home_product.dart';

class ProductDetailPriceLine extends StatelessWidget {
  const ProductDetailPriceLine({required this.product, super.key});

  final HomeProduct product;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (product.hasSale)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: ProductDetailPriceLineStyles.containerDecoration,
            child: const Text(
              'SALE',
              style: ProductDetailPriceLineStyles.saleText,
            ),
          ),
        if (product.hasSale)
          Text(product.price, style: ProductDetailPriceLineStyles.textStyle),
        if (product.hasSale)
          const Text('→', style: SharedPresentationStyles.mutedText),
        Text.rich(
          TextSpan(
            text: product.activePrice,
            style: ProductDetailPriceLineStyles.textStyle2,
            children: [
              TextSpan(
                text: ' ${product.unit}',
                style: SharedPresentationStyles.captionSemibold,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
