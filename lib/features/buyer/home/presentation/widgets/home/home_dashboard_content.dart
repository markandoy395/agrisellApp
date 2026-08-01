import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/constants/agrisell_routes.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/presentation/controllers/home_product_catalog_controller.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/buyer/home/presentation/controllers/home_product_browse_controller.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_product_filter_sheet.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_product_scroll_view.dart';

class HomeDashboardContent extends StatefulWidget {
  const HomeDashboardContent({
    required this.onProductTap,
    required this.catalogController,
    super.key,
  });

  final ValueChanged<HomeProduct> onProductTap;
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

  void _addToBasket(HomeProduct product) {
    if (!product.canOrder) {
      ScaffoldMessenger.of(context).showAppSnackBar(
        SnackBar(content: Text('${product.name} is not accepting orders now.')),
      );
      return;
    }
    BasketController.instance.addProduct(product);
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showAppSnackBar(
      SnackBar(
        content: Text('${product.name} added to your basket.'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () =>
              Navigator.of(context).pushNamed(AgrisellRoutes.basket),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _updates,
      builder: (context, _) {
        final catalog = widget.catalogController;
        return HomeProductScrollView(
          bannerController: _bannerController,
          searchController: _searchController,
          browseController: _browseController,
          products: _browseController.visibleProducts(catalog.products),
          isLoading: catalog.status == HomeProductCatalogStatus.loading,
          loadFailed: catalog.status == HomeProductCatalogStatus.error,
          onRefresh: catalog.load,
          onShowFilters: _showFilters,
          onReset: _resetDiscovery,
          onAddToBasket: _addToBasket,
          onProductTap: widget.onProductTap,
        );
      },
    );
  }
}
