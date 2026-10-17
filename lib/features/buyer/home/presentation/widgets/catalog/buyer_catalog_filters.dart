import 'package:flutter/material.dart';
import 'package:agresell_app/features/shared/products/domain/product_categories.dart';
import '../../controllers/home_product_browse_controller.dart';
import '../../styles/buyer_catalog_styles.dart';
import 'buyer_catalog_icon.dart';

class BuyerCatalogFilters extends StatelessWidget {
  const BuyerCatalogFilters({
    required this.controller,
    required this.count,
    required this.hasMore,
    super.key,
  });
  final HomeProductBrowseController controller;
  final int count;
  final bool hasMore;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        height: 48,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final category = _categories[index];
            final selected = controller.selectedCategory == category;
            return Semantics(
              selected: selected,
              button: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => controller.selectCategory(category),
                child: DecoratedBox(
                  decoration: BuyerCatalogStyles.category(selected),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Center(
                      child: Text(
                        category,
                        style: BuyerCatalogStyles.categoryText(selected),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 12, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '$count${hasMore ? '+' : ''} ${count == 1 ? 'product' : 'products'}',
                style: BuyerCatalogStyles.caption,
              ),
            ),
            PopupMenuButton<HomeProductSort>(
              tooltip: 'Sort products',
              initialValue: controller.sort,
              onSelected: controller.setSort,
              itemBuilder: (_) => [
                for (final option in HomeProductSort.values)
                  CheckedPopupMenuItem(
                    value: option,
                    checked: option == controller.sort,
                    child: Text(
                      option.label,
                      style: BuyerCatalogStyles.caption,
                    ),
                  ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Text('Sort', style: BuyerCatalogStyles.price),
                    const SizedBox(width: 4),
                    const BuyerCatalogIcon('sort', size: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

const _categories = ['All', ...ProductCategories.values];
