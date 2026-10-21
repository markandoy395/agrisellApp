import 'package:agresell_app/features/shared/products/presentation/styles/home_categories_card_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/widgets/responsive_asset_image.dart';
import 'package:agresell_app/features/shared/products/data/home_categories.dart';
import 'package:agresell_app/features/shared/products/domain/home_category.dart';

class HomeCategoriesCard extends StatelessWidget {
  const HomeCategoriesCard({
    this.selectedCategory = 'All',
    this.onSelected,
    super.key,
  });

  final String selectedCategory;
  final ValueChanged<String>? onSelected;
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: HomeCategoriesCardStyles.containerDecoration,
      child: Column(
        children: [
          _CategoryHeader(
            allSelected: selectedCategory == 'All',
            onAllSelected: onSelected == null ? null : () => onSelected!('All'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 14, 10, 14),
            child: homeCategories.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Categories from the backend will appear here.',
                      textAlign: TextAlign.center,
                      style: SharedPresentationStyles.mutedCaption,
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final category in homeCategories) ...[
                          _CategoryTile(
                            category: category,
                            selected:
                                selectedCategory == _normalized(category.label),
                            onTap: onSelected == null
                                ? null
                                : () =>
                                      onSelected!(_normalized(category.label)),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  static String _normalized(String value) => value.replaceAll('\n', ' ');
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.allSelected, this.onAllSelected});

  final bool allSelected;
  final VoidCallback? onAllSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.fromLTRB(16, 3, 8, 3),
      color: AgrisellColors.authGreen,
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Categories',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: HomeCategoriesCardStyles.categoriesText,
            ),
          ),
          TextButton(
            onPressed: onAllSelected,
            style: HomeCategoriesCardStyles.textButtonStyle(allSelected),
            child: Text(allSelected ? 'Showing all' : 'View all'),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.selected,
    this.onTap,
  });

  final HomeCategory category;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final iconSize = width < 380 ? 50.0 : 58.0;

    return Semantics(
      button: true,
      selected: selected,
      label: '${category.label.replaceAll('\n', ' ')} category',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: iconSize,
                height: iconSize,
                padding: EdgeInsets.all(iconSize * 0.2),
                decoration:
                    HomeCategoriesCardStyles.animatedContainerDecoration(
                      selected,
                    ),
                child: ResponsiveAssetImage(
                  asset: category.asset,
                  fit: BoxFit.contain,
                  semanticLabel: category.label,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category.label.replaceAll('\n', ' '),
                textAlign: TextAlign.center,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: HomeCategoriesCardStyles.textStyle(selected),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
