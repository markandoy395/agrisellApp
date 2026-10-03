import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/presentation/controllers/home_product_catalog_controller.dart';
import 'package:agresell_app/features/buyer/home/presentation/controllers/home_product_browse_controller.dart';
import 'package:agresell_app/features/buyer/home/domain/home_banner.dart';
import 'package:agresell_app/features/buyer/home/presentation/screens/sale_products_screen.dart';
import 'package:agresell_app/features/buyer/deals/presentation/screens/deals_and_promos_screen.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_product_filter_sheet.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_product_scroll_view.dart';

class HomeDashboardContent extends StatefulWidget {
  const HomeDashboardContent({
    required this.onProductTap,
    required this.catalogController,
    super.key,
  });

  final void Function(
    HomeProduct product,
    HomeProductBrowseController browseController,
  )
  onProductTap;
  final HomeProductCatalogController catalogController;

  @override
  State<HomeDashboardContent> createState() => _HomeDashboardContentState();
}

class _HomeDashboardContentState extends State<HomeDashboardContent> {
  late final TextEditingController _searchController;
  late final PageController _bannerController;
  late final HomeProductBrowseController _browseController;
  late final Listenable _updates;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _bannerController = PageController(initialPage: 1, viewportFraction: 0.78);
    _browseController = HomeProductBrowseController();
    _updates = Listenable.merge([_browseController, widget.catalogController]);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bannerController.dispose();
    _browseController.dispose();
    super.dispose();
  }

  void _resetDiscovery() {
    _searchController.clear();
    _browseController.resetDiscoveryOptions();
  }

  void _showFilters() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AgrisellColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => HomeProductFilterSheet(
        controller: _browseController,
        onReset: _resetDiscovery,
      ),
    );
  }

  void _openCampaignBanner(HomeBanner banner) {
    final saleId = banner.campaignSaleId;
    if (saleId == null) return;
    Navigator.of(context).push(
      agrisellMaterialPageRoute<void>(
        builder: (_) => SaleProductsScreen(
          title: banner.subtitle.isEmpty ? 'Sale products' : banner.subtitle,
          campaignSaleId: saleId,
        ),
      ),
    );
  }

  void _openAllSaleProducts(List<HomeProduct> products) {
    Navigator.of(context).push(
      agrisellMaterialPageRoute<void>(
        builder: (_) => SaleProductsScreen(
          title: 'All sale products',
          initialProducts: products,
        ),
      ),
    );
  }

  void _openDealsAndPromos() {
    Navigator.of(context).push(
      agrisellMaterialPageRoute<void>(
        builder: (_) => const DealsAndPromosScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _updates,
      builder: (context, _) {
        final catalog = widget.catalogController;
        final saleProducts = catalog.products
            .where((product) => product.canOrder && product.hasSale)
            .toList(growable: false);
        return HomeProductScrollView(
          bannerController: _bannerController,
          searchController: _searchController,
          browseController: _browseController,
          products: _browseController.visibleProducts(catalog.products),
          saleProducts: saleProducts,
          onBannerTap: _openCampaignBanner,
          onViewAllSales: () => _openAllSaleProducts(saleProducts),
          onOpenDeals: _openDealsAndPromos,
          isLoading: catalog.status == HomeProductCatalogStatus.loading,
          loadFailed: catalog.status == HomeProductCatalogStatus.error,
          isLoadingMore: catalog.isLoadingMore,
          hasMore: catalog.hasMore,
          onRefresh: catalog.load,
          onLoadMore: catalog.loadMore,
          onShowFilters: _showFilters,
          onReset: _resetDiscovery,
          onProductTap: (product) =>
              widget.onProductTap(product, _browseController),
        );
      },
    );
  }
}
