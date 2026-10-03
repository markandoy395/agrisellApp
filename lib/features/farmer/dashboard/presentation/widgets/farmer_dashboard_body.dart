part of 'package:agresell_app/features/farmer/dashboard/presentation/screens/farmer_dashboard_screen.dart';

class _FarmerDashboardBody extends StatelessWidget {
  const _FarmerDashboardBody({required this.state});

  final _FarmerDashboardScreenState state;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = FarmerDashboardStyles.horizontalPadding(width);
    final navClearance = FarmerDashboardStyles.navClearance(
      MediaQuery.paddingOf(context).bottom,
    );

    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        if (state._verificationDetails?.isNeedsInformation == true)
          SliverToBoxAdapter(
            child: FarmerInformationRequestBanner(
              details: state._verificationDetails!,
              onTap: state._openResubmitInformation,
            ),
          ),
        SliverToBoxAdapter(
          child: _FarmerAddProductButton(
            horizontalPadding: horizontalPadding,
            isEnabled: state._canPostProducts,
            onPressed: state._openAddProductScreen,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: FarmerDashboardStyles.tabsPadding(horizontalPadding),
            child: _FarmerDashboardTabs(
              activeTab: state._activeTab,
              onChanged: state._selectTab,
            ),
          ),
        ),
        _FarmerDashboardTabContent(
          activeTab: state._activeTab,
          isLoadingProducts: state._isLoadingProducts,
          hasProducts: state._products.isNotEmpty,
          visibleProducts: state._visibleProducts,
          onIndexOfProduct: state._products.indexOf,
          restockingProductIds: state._restockingProductIds,
          selectedCategory: state._selectedCategory,
          horizontalPadding: horizontalPadding,
          gridSpacing: FarmerDashboardStyles.gridSpacing(width),
          productRatio: FarmerDashboardStyles.productRatio(width),
          onEdit: state._openEditProduct,
          onRestock: state._openRestockProduct,
          onCategorySelected: state._selectCategory,
        ),
        SliverToBoxAdapter(child: SizedBox(height: navClearance)),
      ],
    );
  }
}
