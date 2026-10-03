import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/buyer/home/presentation/styles/buyer_home_categories_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/widgets/responsive_asset_image.dart';
import 'package:agresell_app/features/shared/products/data/home_categories.dart';
import 'package:agresell_app/features/shared/products/domain/home_category.dart';

class BuyerHomeCategories extends StatelessWidget {
  const BuyerHomeCategories({
    this.selectedCategory = 'All',
    this.onSelected,
    super.key,
  });

  final String selectedCategory;
  final ValueChanged<String>? onSelected;

  @override
  Widget build(BuildContext context) {
    if (homeCategories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Categories from the backend will appear here.',
          textAlign: TextAlign.center,
          style: SharedPresentationStyles.mutedCaption,
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final category in homeCategories) ...[
            _BuyerCategoryItem(
              category: category,
              selected: selectedCategory == _normalized(category.label),
              onTap: onSelected == null
                  ? null
                  : () => onSelected!(_normalized(category.label)),
            ),
            const SizedBox(width: 8),
          ],
          _CircleCategoryButton(
            label: 'Show all',
            selected: selectedCategory == 'All',
            isShowAll: true,
            onTap: onSelected == null ? null : () => onSelected!('All'),
            circleChild: const Icon(
              Icons.grid_view_rounded,
              color: AgrisellColors.surface,
              size: 23,
            ),
          ),
        ],
      ),
    );
  }

  static String _normalized(String value) => value.replaceAll('\n', ' ');
}

class _BuyerCategoryItem extends StatelessWidget {
  const _BuyerCategoryItem({
    required this.category,
    required this.selected,
    this.onTap,
  });

  final HomeCategory category;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final label = category.label.replaceAll('\n', ' ');

    return _CircleCategoryButton(
      label: label,
      selected: selected,
      onTap: onTap,
      circleChild: ExcludeSemantics(
        child: ResponsiveAssetImage(
          asset: category.asset,
          fit: BoxFit.contain,
          semanticLabel: label,
        ),
      ),
    );
  }
}

class _CircleCategoryButton extends StatelessWidget {
  const _CircleCategoryButton({
    required this.label,
    required this.selected,
    required this.circleChild,
    this.isShowAll = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final Widget circleChild;
  final bool isShowAll;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: isShowAll ? label : '$label category',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 54,
                height: 54,
                padding: EdgeInsets.all(isShowAll ? 0 : 10),
                decoration:
                    BuyerHomeCategoriesStyles.animatedContainerDecoration(
                      isShowAll,
                      selected,
                    ),
                child: circleChild,
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 64,
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: BuyerHomeCategoriesStyles.labelText(
                    selected,
                    isShowAll,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
