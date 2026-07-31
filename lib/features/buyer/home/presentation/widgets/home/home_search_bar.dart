import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
    this.activeFilterCount = 0,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final int activeFilterCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AgrisellColors.authGreen.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(
            Icons.search_rounded,
            color: AgrisellColors.authGreen,
            size: 22,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              key: const ValueKey('home-product-search'),
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: const TextStyle(
                color: AgrisellColors.brandBlack,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                hintText: 'Search in AgriSell',
                hintStyle: TextStyle(
                  color: AgrisellColors.mutedText,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                tooltip: 'Clear product search',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close_rounded, size: 19),
              );
            },
          ),
          Semantics(
            button: true,
            label: activeFilterCount == 0
                ? 'Open product filters'
                : 'Open product filters, $activeFilterCount active',
            child: InkWell(
              key: const ValueKey('home-product-filter-button'),
              onTap: onFilterTap,
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 42,
                height: 42,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.tune_rounded,
                      color: AgrisellColors.authGreen,
                      size: 22,
                    ),
                    if (activeFilterCount > 0)
                      Positioned(
                        right: 2,
                        top: 1,
                        child: CircleAvatar(
                          radius: 8,
                          backgroundColor: AgrisellColors.authGreen,
                          child: Text(
                            '$activeFilterCount',
                            style: const TextStyle(
                              color: AgrisellColors.surface,
                              fontSize: 12,
                              height: 1,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
