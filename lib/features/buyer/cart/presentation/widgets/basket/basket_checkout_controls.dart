import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/buyer/cart/presentation/widgets/basket/basket_price_formatter.dart';

class BasketCheckoutSummary extends StatelessWidget {
  const BasketCheckoutSummary({
    required this.allSelected,
    required this.hasItems,
    required this.total,
    required this.onAllChanged,
    this.selectedQuantity = 0,
    super.key,
  });

  final bool allSelected;
  final bool hasItems;
  final double total;
  final ValueChanged<bool> onAllChanged;
  final int selectedQuantity;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 58,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: _AllSelector(
              value: allSelected,
              enabled: hasItems,
              onChanged: onAllChanged,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  selectedQuantity == 0
                      ? 'Selected total'
                      : '$selectedQuantity selected',
                  maxLines: 1,
                  style: const TextStyle(
                    color: AgrisellColors.mutedText,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  formatBasketPeso(total),
                  maxLines: 1,
                  style: const TextStyle(
                    color: AgrisellColors.authGreen,
                    fontSize: 16,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AllSelector extends StatelessWidget {
  const _AllSelector({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: value,
      label: 'Select all basket items',
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: enabled ? () => onChanged(!value) : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 34,
              child: Checkbox(
                value: value,
                visualDensity: VisualDensity.compact,
                side: const BorderSide(color: AgrisellColors.checkboxBorder),
                activeColor: AgrisellColors.authGreen,
                onChanged: enabled
                    ? (checked) => onChanged(checked ?? false)
                    : null,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'All',
              style: TextStyle(
                color: enabled
                    ? AgrisellColors.brandBlack
                    : AgrisellColors.mutedText,
                fontSize: 15,
                height: 1,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
