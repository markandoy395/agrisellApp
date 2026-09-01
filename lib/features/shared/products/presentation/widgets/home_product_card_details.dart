import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
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
              fontSize: titleSize > 12 ? titleSize - 1 : titleSize,
              height: 1.05,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          _ProductCardPrice(product: product),
          const SizedBox(height: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductCardMeta(
                icon: Icons.inventory_2_outlined,
                value: product.availableQuantityValue,
                emphasis: true,
              ),
              const SizedBox(height: 4),
              _ProductCardMeta(
                icon: Icons.calendar_month_outlined,
                value: product.freshnessLabel ?? product.harvestDate,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductCardMeta extends StatelessWidget {
  const _ProductCardMeta({
    required this.icon,
    required this.value,
    this.emphasis = false,
  });

  final IconData icon;
  final String value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AgrisellColors.authGreen),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AgrisellColors.mutedText,
              fontSize: 12,
              height: 1,
              fontWeight: emphasis ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductCardPrice extends StatelessWidget {
  const _ProductCardPrice({required this.product});

  final HomeProduct product;

  @override
  Widget build(BuildContext context) {
    const activeStyle = TextStyle(
      color: AgrisellColors.authGreen,
      fontSize: 14,
      height: 1.05,
      fontWeight: FontWeight.w700,
    );
    if (!product.hasSale) {
      return Text.rich(
        TextSpan(
          text: product.price,
          style: activeStyle,
          children: [
            TextSpan(
              text: ' ${product.unit}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return Row(
      children: [
        Text(
          product.price,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 12,
            decoration: TextDecoration.lineThrough,
            decorationColor: Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Text('→', style: TextStyle(color: AgrisellColors.mutedText)),
        ),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: product.activePrice,
              style: activeStyle,
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
        ),
      ],
    );
  }
}
