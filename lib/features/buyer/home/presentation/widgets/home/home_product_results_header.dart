import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/home/presentation/controllers/home_product_browse_controller.dart';

class HomeProductResultsHeader extends StatelessWidget {
  const HomeProductResultsHeader({
    required this.resultCount,
    required this.savedCount,
    required this.savedOnly,
    required this.sort,
    required this.onSavedOnlyChanged,
    required this.onSortChanged,
    super.key,
  });

  final int resultCount;
  final int savedCount;
  final bool savedOnly;
  final HomeProductSort sort;
  final ValueChanged<bool> onSavedOnlyChanged;
  final ValueChanged<HomeProductSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fresh picks',
                style: TextStyle(
                  color: AgrisellColors.headingGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '$resultCount ${resultCount == 1 ? 'product' : 'products'} found',
                style: const TextStyle(
                  color: AgrisellColors.mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _SavedButton(
          count: savedCount,
          selected: savedOnly,
          onTap: () => onSavedOnlyChanged(!savedOnly),
        ),
        const SizedBox(width: 6),
        PopupMenuButton<HomeProductSort>(
          initialValue: sort,
          onSelected: onSortChanged,
          tooltip: 'Sort products',
          icon: const Icon(
            Icons.swap_vert_rounded,
            color: AgrisellColors.authGreen,
          ),
          itemBuilder: (context) => [
            for (final option in HomeProductSort.values)
              PopupMenuItem(
                value: option,
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: option == sort
                          ? const Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: AgrisellColors.authGreen,
                            )
                          : null,
                    ),
                    Text(option.label, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _SavedButton extends StatelessWidget {
  const _SavedButton({
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Show saved products, $count saved',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: selected ? AgrisellColors.authGreen : AgrisellColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AgrisellColors.authGreen),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? Icons.favorite_rounded : Icons.favorite_border,
                size: 17,
                color: selected
                    ? AgrisellColors.surface
                    : AgrisellColors.authGreen,
              ),
              const SizedBox(width: 4),
              Text(
                '$count',
                style: TextStyle(
                  color: selected
                      ? AgrisellColors.surface
                      : AgrisellColors.authGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
