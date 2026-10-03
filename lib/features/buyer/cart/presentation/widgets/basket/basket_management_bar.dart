import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/buyer/cart/presentation/styles/basket_management_bar_styles.dart';
import 'package:flutter/material.dart';

class BasketManagementBar extends StatelessWidget {
  const BasketManagementBar({
    required this.itemCount,
    required this.selectedCount,
    required this.onRemoveSelected,
    super.key,
  });

  final int itemCount;
  final int selectedCount;
  final VoidCallback onRemoveSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                style: SharedPresentationStyles.headingBodyExtraBold,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BasketManagementBarStyles.containerDecoration,
                child: Text(
                  '$selectedCount selected',
                  style: BasketManagementBarStyles.textStyle,
                ),
              ),
            ],
          ),
        ),
        TextButton.icon(
          key: const ValueKey('remove-selected-items'),
          onPressed: selectedCount == 0 ? null : onRemoveSelected,
          style: BasketManagementBarStyles.textButtonStyle,
          icon: const Icon(Icons.delete_outline_rounded, size: 18),
          label: const Text(
            'Remove',
            style: SharedPresentationStyles.captionBold,
          ),
        ),
      ],
    );
  }
}
