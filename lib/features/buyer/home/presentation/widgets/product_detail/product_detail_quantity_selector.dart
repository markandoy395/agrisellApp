import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

class ProductDetailQuantitySelector extends StatelessWidget {
  const ProductDetailQuantitySelector({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.enabled = true,
    super.key,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AgrisellColors.forestSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuantityButton(
            label: 'Decrease quantity',
            icon: Icons.remove_rounded,
            onTap: enabled && quantity > 1 ? onDecrement : null,
          ),
          SizedBox(
            width: 30,
            child: Text(
              quantity.toString().padLeft(2, '0'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AgrisellColors.headingGreen,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _QuantityButton(
            label: 'Increase quantity',
            icon: Icons.add_rounded,
            onTap: enabled && quantity < 99 ? onIncrement : null,
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: label,
      onPressed: onTap,
      icon: Icon(icon),
      color: AgrisellColors.authGreen,
      disabledColor: AgrisellColors.deliveryGray,
      iconSize: 18,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 34, height: 36),
    );
  }
}
