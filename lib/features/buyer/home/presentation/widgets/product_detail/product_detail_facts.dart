import 'package:flutter/material.dart';

import 'package:agresell_app/features/buyer/home/presentation/styles/product_detail_info_card_styles.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';

class ProductDetailFacts extends StatelessWidget {
  const ProductDetailFacts({required this.product, super.key});

  final HomeProduct product;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: ProductDetailInfoCardStyles.factWrapSpacing,
    runSpacing: ProductDetailInfoCardStyles.factWrapRunSpacing,
    children: [
      ProductDetailFact(
        icon: Icons.inventory_2_outlined,
        text: product.availableQuantityLabel,
      ),
      ProductDetailFact(
        icon: Icons.calendar_today_outlined,
        text: product.harvestDate,
      ),
      if (product.freshnessLabel case final freshness?)
        ProductDetailFact(
          icon: product.isNearFreshnessDeadline
              ? Icons.warning_amber_rounded
              : Icons.event_available_outlined,
          text: freshness,
        ),
    ],
  );
}

class ProductDetailStorageInstructions extends StatelessWidget {
  const ProductDetailStorageInstructions({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Icon(
        Icons.thermostat_outlined,
        color: ProductDetailInfoCardStyles.factIconColor,
        size: ProductDetailInfoCardStyles.factIconSize,
      ),
      const SizedBox(width: ProductDetailInfoCardStyles.factItemSpacing),
      Expanded(
        child: Text(
          'Storage: $text',
          style: ProductDetailInfoCardStyles.storageTextStyle,
        ),
      ),
    ],
  );
}

class ProductDetailFact extends StatelessWidget {
  const ProductDetailFact({
    required this.icon,
    required this.text,
    super.key,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        color: ProductDetailInfoCardStyles.factIconColor,
        size: ProductDetailInfoCardStyles.factIconSize,
      ),
      const SizedBox(width: ProductDetailInfoCardStyles.factItemSpacing),
      Text(text, style: ProductDetailInfoCardStyles.factTextStyle),
    ],
  );
}

class ProductDetailSectionTitle extends StatelessWidget {
  const ProductDetailSectionTitle({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: ProductDetailInfoCardStyles.sectionTitleStyle,
  );
}
