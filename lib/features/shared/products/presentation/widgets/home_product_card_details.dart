import 'package:agresell_app/features/shared/products/presentation/styles/home_product_card_details_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';

class HomeProductCardDetails extends StatelessWidget {
  const HomeProductCardDetails({required this.product, super.key});

  final HomeProduct product;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: HomeProductCardDetailsStyles.containerDecoration,
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: HomeProductCardDetailsStyles.textStyle,
          ),
          const SizedBox(height: 2),
          _ProductCardPrice(product: product),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductCardMeta(
                icon: Icons.inventory_2_outlined,
                value: product.availableQuantityValue,
                emphasis: true,
              ),
              const SizedBox(height: 5),
              _ProductCardMeta(
                icon: Icons.calendar_today_outlined,
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
        Icon(icon, size: 14, color: AgrisellColors.mutedText),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: HomeProductCardDetailsStyles.valueText(emphasis),
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
    const activeStyle = HomeProductCardDetailsStyles.textStyle2;
    if (!product.hasSale) {
      return Text.rich(
        TextSpan(
          text: product.price,
          style: activeStyle,
          children: [
            TextSpan(
              text: ' ${product.unit}',
              style: SharedPresentationStyles.captionMedium,
            ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return Row(
      children: [
        Text(product.price, style: SharedPresentationStyles.originalPrice),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Text('→', style: SharedPresentationStyles.mutedText),
        ),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: product.activePrice,
              style: activeStyle,
              children: [
                TextSpan(
                  text: ' ${product.unit}',
                  style: SharedPresentationStyles.captionMedium,
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
