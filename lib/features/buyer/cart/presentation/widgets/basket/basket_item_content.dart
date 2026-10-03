import 'package:agresell_app/features/buyer/cart/presentation/styles/basket_item_content_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/orders/domain/basket_cart_item.dart';
import 'package:agresell_app/features/shared/payments/price_formatter.dart';
import 'package:agresell_app/features/buyer/cart/presentation/widgets/basket/quantity_stepper.dart';

class BasketItemDetails extends StatelessWidget {
  const BasketItemDetails({required this.item, super.key});

  final BasketCartItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.productName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: BasketItemContentStyles.textStyle,
        ),
        const SizedBox(height: 7),
        Wrap(
          spacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (item.hasSale)
              Text(
                item.originalPriceLabel!,
                style: SharedPresentationStyles.originalPrice,
              ),
            if (item.hasSale)
              const Text('→', style: SharedPresentationStyles.mutedText),
            Text(
              '${item.priceLabel} ${item.unit}',
              style: SharedPresentationStyles.greenBodyExtraBold,
            ),
          ],
        ),
        const SizedBox(height: 10),
        _InfoLine(
          icon: Icons.eco_outlined,
          text: 'Harvested ${item.harvestDate}',
        ),
        const SizedBox(height: 7),
        _InfoLine(icon: Icons.inventory_2_outlined, text: item.availableWeight),
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AgrisellColors.mutedText),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: SharedPresentationStyles.mutedCaptionMedium,
          ),
        ),
      ],
    );
  }
}

class BasketItemSummary extends StatelessWidget {
  const BasketItemSummary({
    required this.item,
    required this.onDecrement,
    required this.onIncrement,
    super.key,
  });

  final BasketCartItem item;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text.rich(
            TextSpan(
              text: 'Subtotal\n',
              style: SharedPresentationStyles.mutedCaptionSemiboldLoose,
              children: [
                TextSpan(
                  text: formatBasketPeso(item.pricePerKg * item.quantity),
                  style: SharedPresentationStyles.greenTitleExtraBold,
                ),
              ],
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'Quantity',
              style: SharedPresentationStyles.mutedCaptionSemibold,
            ),
            const SizedBox(height: 4),
            QuantityStepper(
              quantity: item.quantity,
              onDecrement: onDecrement,
              onIncrement: onIncrement,
            ),
          ],
        ),
      ],
    );
  }
}
