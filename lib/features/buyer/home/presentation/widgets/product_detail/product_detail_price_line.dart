import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
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
            decoration: BoxDecoration(
              color: AgrisellColors.authGreen,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'SALE',
              style: TextStyle(
                color: AgrisellColors.surface,
                fontSize: 12,
                height: 1,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        if (product.hasSale)
          Text(
            product.price,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 14,
              decoration: TextDecoration.lineThrough,
              decorationColor: Colors.red,
              fontWeight: FontWeight.w700,
            ),
          ),
        if (product.hasSale)
          const Text('→', style: TextStyle(color: AgrisellColors.mutedText)),
        Text.rich(
          TextSpan(
            text: product.activePrice,
            style: const TextStyle(
              color: AgrisellColors.authGreen,
              fontSize: 15,
              height: 1,
              fontWeight: FontWeight.w800,
            ),
            children: [
              TextSpan(
                text: ' ${product.unit}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
