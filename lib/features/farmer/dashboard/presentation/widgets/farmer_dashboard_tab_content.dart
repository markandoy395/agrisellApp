part of 'package:agresell_app/features/farmer/dashboard/presentation/screens/farmer_dashboard_screen.dart';

class _FarmerDashboardTabContent extends StatelessWidget {
  const _FarmerDashboardTabContent({
    required this.activeTab,
    required this.isLoadingProducts,
    required this.hasProducts,
    required this.visibleProducts,
    required this.onIndexOfProduct,
    required this.restockingProductIds,
    required this.selectedCategory,
    required this.horizontalPadding,
    required this.gridSpacing,
    required this.productRatio,
    required this.onEdit,
    required this.onRestock,
    required this.onCategorySelected,
  });

  final _FarmerDashboardTab activeTab;
  final bool isLoadingProducts;
  final bool hasProducts;
  final List<FarmerDashboardProduct> visibleProducts;
  final int Function(FarmerDashboardProduct) onIndexOfProduct;
  final Set<int> restockingProductIds;
  final String selectedCategory;
  final double horizontalPadding;
  final double gridSpacing;
  final double productRatio;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onRestock;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    if (activeTab == _FarmerDashboardTab.products) {
      if (!hasProducts && isLoadingProducts) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: FarmerDashboardStyles.loadingPadding,
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      }
      if (!hasProducts) {
        return const SliverToBoxAdapter(
          child: _FarmerDashboardEmptyState(
            message: 'Products from the backend will appear here.',
          ),
        );
      }
      if (visibleProducts.isEmpty) {
        return const SliverToBoxAdapter(
          child: _FarmerDashboardEmptyState(
            message: 'No products match your search or category.',
          ),
        );
      }
      return SliverPadding(
        padding: FarmerDashboardStyles.contentPadding(horizontalPadding),
        sliver: SliverGrid.builder(
          itemCount: visibleProducts.length,
          gridDelegate: FarmerDashboardStyles.gridDelegate(
            gridSpacing: gridSpacing,
            productRatio: productRatio,
          ),
          itemBuilder: (context, index) {
            final product = visibleProducts[index];
            return _FarmerProductCard(
              product: product,
              onEdit: () => onEdit(onIndexOfProduct(product)),
              onRestock: () => onRestock(onIndexOfProduct(product)),
              isRestocking:
                  product.commodityId != null &&
                  restockingProductIds.contains(product.commodityId),
            );
          },
        ),
      );
    }

    return SliverPadding(
      padding: FarmerDashboardStyles.contentPadding(horizontalPadding),
      sliver: SliverToBoxAdapter(
        child: HomeCategoriesCard(
          selectedCategory: selectedCategory,
          onSelected: onCategorySelected,
        ),
      ),
    );
  }
}
