import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

enum FarmerShopTab { products, categories }

class FarmerShopTabs extends StatelessWidget {
  const FarmerShopTabs({
    required this.activeTab,
    required this.onChanged,
    super.key,
  });

  final FarmerShopTab activeTab;
  final ValueChanged<FarmerShopTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: const BoxDecoration(
        color: AgrisellColors.surface,
        border: Border(bottom: BorderSide(color: AgrisellColors.borderLine)),
      ),
      child: ClipRect(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TabButton(
              label: 'Products',
              isActive: activeTab == FarmerShopTab.products,
              onTap: () => onChanged(FarmerShopTab.products),
            ),
            _TabButton(
              label: 'Categories',
              isActive: activeTab == FarmerShopTab.categories,
              onTap: () => onChanged(FarmerShopTab.categories),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AgrisellColors.authGreen : AgrisellColors.surface;
    final textColor = isActive
        ? AgrisellColors.surface
        : AgrisellColors.brandBlack;
    final borderRadius = isActive
        ? const BorderRadius.vertical(top: Radius.circular(22))
        : BorderRadius.zero;

    return Expanded(
      child: Material(
        color: color,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                height: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
