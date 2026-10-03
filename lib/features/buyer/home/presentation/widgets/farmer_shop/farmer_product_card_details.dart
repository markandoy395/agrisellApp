import 'package:agresell_app/features/buyer/home/presentation/styles/farmer_product_card_details_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/home/presentation/styles/farmer_product_card_styles.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';

class FarmerProductCardDetails extends StatelessWidget {
  const FarmerProductCardDetails({required this.product, super.key});

  final HomeProduct product;

  @override
  Widget build(BuildContext context) {
    final textColor = product.isAvailable
        ? AgrisellColors.brandBlack
        : AgrisellColors.brandBlack.withValues(alpha: 0.64);
    final valueColor = product.isAvailable
        ? AgrisellColors.authGreen
        : AgrisellColors.mutedText;

    return SizedBox(
      height: FarmerProductCardStyles.detailsHeight,
      width: double.infinity,
      child: Padding(
        padding: FarmerProductCardStyles.detailsPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FarmerProductCardDetailsStyles.textStyle(textColor),
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                text: product.price,
                style: FarmerProductCardDetailsStyles.textSpanStyle(valueColor),
                children: [
                  TextSpan(
                    text: ' ${product.unit}',
                    style: FarmerProductCardStyles.unitText,
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            FarmerProductCardMeta(
              icon: Icons.inventory_2_outlined,
              value: product.availableQuantityLabel,
              color: valueColor,
            ),
            const SizedBox(height: FarmerProductCardStyles.metaSpacing),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: AgrisellColors.mutedText,
                  size: FarmerProductCardStyles.metaIconSize,
                ),
                const SizedBox(width: FarmerProductCardStyles.metaSpacing),
                Expanded(
                  child: Text(
                    product.freshnessLabel ?? product.harvestDate,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FarmerProductCardStyles.harvestDateText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FarmerProductCardMeta extends StatelessWidget {
  const FarmerProductCardMeta({
    required this.icon,
    required this.value,
    required this.color,
    super.key,
  });

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: color, size: FarmerProductCardStyles.metaIconSize),
      const SizedBox(width: FarmerProductCardStyles.metaSpacing),
      Expanded(
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: FarmerProductCardDetailsStyles.valueText(color),
        ),
      ),
    ],
  );
}
