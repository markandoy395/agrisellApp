import 'package:agresell_app/features/buyer/home/presentation/styles/farmer_shop_content_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer_shop/category_filter.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer_shop/farmer_product_grid.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer_shop/farmer_shop_tabs.dart';

class FarmerShopContent extends StatelessWidget {
  const FarmerShopContent({
    required this.activeTab,
    required this.categoryCounts,
    required this.selectedCategory,
    required this.products,
    required this.isLoading,
    required this.loadFailed,
    required this.onRetry,
    required this.onTabChanged,
    required this.onCategoryChanged,
    required this.onProductTap,
    super.key,
  });

  final FarmerShopTab activeTab;
  final Map<String, int> categoryCounts;
  final String? selectedCategory;
  final List<HomeProduct> products;
  final bool isLoading;
  final bool loadFailed;
  final VoidCallback onRetry;
  final ValueChanged<FarmerShopTab> onTabChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<HomeProduct> onProductTap;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 8;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: FarmerShopContentStyles.containerDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FarmerShopTabs(activeTab: activeTab, onChanged: onTabChanged),
          Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: FarmerShopContentStyles.containerDecoration2,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  if (activeTab == FarmerShopTab.categories)
                    SliverToBoxAdapter(
                      child: CategoryFilter(
                        categoryCounts: categoryCounts,
                        selectedCategory: selectedCategory,
                        onChanged: onCategoryChanged,
                      ),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    sliver: FarmerProductGrid(
                      products: products,
                      isLoading: isLoading,
                      loadFailed: loadFailed,
                      onRetry: onRetry,
                      onProductTap: onProductTap,
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
