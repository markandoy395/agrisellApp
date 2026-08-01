import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
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
          style: const TextStyle(
            color: AgrisellColors.brandBlack,
            fontSize: 15,
            height: 1.15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          '${item.priceLabel} ${item.unit}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AgrisellColors.authGreen,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
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
            style: const TextStyle(
              color: AgrisellColors.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
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
              style: const TextStyle(
                color: AgrisellColors.mutedText,
                fontSize: 12,
                height: 1.3,
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(
                  text: formatBasketPeso(item.pricePerKg * item.quantity),
                  style: const TextStyle(
                    color: AgrisellColors.authGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
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
              style: TextStyle(
                color: AgrisellColors.mutedText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
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
