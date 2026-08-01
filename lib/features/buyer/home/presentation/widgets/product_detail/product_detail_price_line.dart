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
        Text.rich(
          TextSpan(
            text: product.price,
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
