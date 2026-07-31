import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';

class HomeProductCardDetails extends StatelessWidget {
  const HomeProductCardDetails({
    required this.product,
    required this.titleSize,
    super.key,
  });

  final HomeProduct product;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AgrisellColors.brandBlack,
              fontSize: titleSize,
              height: 1.05,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text.rich(
            TextSpan(
              text: product.price,
              style: const TextStyle(
                color: AgrisellColors.authGreen,
                fontSize: 14,
                height: 1.05,
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(
                  text: ' ${product.unit}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            product.availableQuantityLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AgrisellColors.mutedText,
              fontSize: 12,
              height: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Harvest: ${product.harvestDate}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AgrisellColors.mutedText,
              fontSize: 12,
              height: 1,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
