import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

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
                style: const TextStyle(
                  color: AgrisellColors.headingGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AgrisellColors.forestSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$selectedCount selected',
                  style: const TextStyle(
                    color: AgrisellColors.forestDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        TextButton.icon(
          key: const ValueKey('remove-selected-items'),
          onPressed: selectedCount == 0 ? null : onRemoveSelected,
          style: TextButton.styleFrom(
            foregroundColor: AgrisellColors.statusRedText,
            disabledForegroundColor: AgrisellColors.mutedText,
            minimumSize: const Size(0, 36),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: const Icon(Icons.delete_outline_rounded, size: 18),
          label: const Text(
            'Remove',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
