import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';

class CategoryFilter extends StatelessWidget {
  const CategoryFilter({
    required this.categoryCounts,
    required this.selectedCategory,
    required this.onChanged,
    super.key,
  });

  final Map<String, int> categoryCounts;
  final String? selectedCategory;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final categories = categoryCounts.keys.toList(growable: false)..sort();
    if (categories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Text(
            'Categories from the backend will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AgrisellColors.mutedText, fontSize: 12),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var index = 0; index < categories.length; index++)
          _CategoryRow(
            category: categories[index],
            count: categoryCounts[categories[index]] ?? 0,
            isSelected: selectedCategory == categories[index],
            showDivider: index != categories.length - 1,
            onTap: () => onChanged(categories[index]),
          ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.count,
    required this.isSelected,
    required this.showDivider,
    required this.onTap,
  });

  final String category;
  final int count;
  final bool isSelected;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected
        ? AgrisellColors.surface
        : AgrisellColors.brandBlack;
    return Material(
      color: isSelected
          ? AgrisellColors.authGreen
          : AgrisellColors.homeBackground,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            border: showDivider
                ? const Border(
                    bottom: BorderSide(color: AgrisellColors.dividerLine),
                  )
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  category,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text('($count)', style: TextStyle(color: foreground)),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: foreground),
            ],
          ),
        ),
      ),
    );
  }
}
