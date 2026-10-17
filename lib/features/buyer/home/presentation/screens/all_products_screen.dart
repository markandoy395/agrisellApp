import 'package:flutter/material.dart';
import 'package:agresell_app/features/auth/presentation/auth_role_gate.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/presentation/controllers/home_product_catalog_controller.dart';
import '../controllers/home_product_browse_controller.dart';
import '../styles/buyer_catalog_styles.dart';
import '../widgets/catalog/buyer_catalog_bottom_nav.dart';
import '../widgets/catalog/buyer_catalog_filters.dart';
import '../widgets/catalog/buyer_catalog_grid.dart';
import '../widgets/catalog/buyer_catalog_icon.dart';
import '../widgets/catalog/buyer_catalog_price.dart';
import '../widgets/home/home_catalog_footer.dart';
import '../widgets/home/home_catalog_status.dart';
import '../widgets/home/home_empty_catalog_sliver.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({
    required this.catalogController,
    required this.browseController,
    required this.onProductTap,
    this.badgeCounts = const {},
    super.key,
  });
  final HomeProductCatalogController catalogController;
  final HomeProductBrowseController browseController;
  final ValueChanged<HomeProduct> onProductTap;
  final Map<int, int> badgeCounts;

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  late final _search = TextEditingController(
    text: widget.browseController.query,
  );
  late final _updates = Listenable.merge([
    widget.catalogController,
    widget.browseController,
  ]);
  bool _searching = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _loadMore(ScrollNotification event) {
    if (event.depth == 0 &&
        event.metrics.axis == Axis.vertical &&
        event.metrics.extentAfter < 450) {
      widget.catalogController.loadMore();
    }
    return false;
  }

  List<HomeProduct> _products() {
    final browse = widget.browseController;
    final products = browse.visibleProducts(widget.catalogController.products);
    if (browse.sort == HomeProductSort.priceLowToHigh ||
        browse.sort == HomeProductSort.priceHighToLow) {
      final direction = browse.sort == HomeProductSort.priceLowToHigh ? 1 : -1;
      products.sort(
        (a, b) =>
            direction *
            catalogPrice(a.activePrice).compareTo(catalogPrice(b.activePrice)),
      );
    }
    return products;
  }

  @override
  Widget build(BuildContext context) => AuthRoleGate(
    requiredRole: AuthRole.buyer,
    child: Theme(
      data: Theme.of(context).copyWith(appBarTheme: BuyerCatalogStyles.appBar),
      child: Scaffold(
        backgroundColor: BuyerCatalogStyles.background,
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.pop(context),
            icon: const BuyerCatalogIcon('back', size: 22),
          ),
          title: _searching
              ? TextField(
                  controller: _search,
                  autofocus: true,
                  style: BuyerCatalogStyles.caption,
                  decoration: BuyerCatalogStyles.search,
                  onChanged: widget.browseController.updateQuery,
                )
              : const Text('All Products'),
          actions: [
            IconButton(
              tooltip: _searching ? 'Close search' : 'Search products',
              onPressed: () => setState(() {
                _searching = !_searching;
                if (!_searching) {
                  _search.clear();
                  widget.browseController.updateQuery('');
                }
              }),
              icon: _searching
                  ? const Icon(Icons.close)
                  : const BuyerCatalogIcon('search'),
            ),
          ],
        ),
        bottomNavigationBar: BuyerCatalogBottomNav(
          badgeCounts: widget.badgeCounts,
        ),
        body: AnimatedBuilder(
          animation: _updates,
          builder: (context, _) {
            final catalog = widget.catalogController;
            final products = _products();
            final loading = catalog.status == HomeProductCatalogStatus.loading;
            final failed = catalog.status == HomeProductCatalogStatus.error;
            return RefreshIndicator(
              onRefresh: catalog.load,
              child: NotificationListener<ScrollNotification>(
                onNotification: _loadMore,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: BuyerCatalogFilters(
                        controller: widget.browseController,
                        count: products.length,
                        hasMore: catalog.hasMore,
                      ),
                    ),
                    if (products.isNotEmpty && (loading || failed))
                      HomeCatalogStatus(failed: failed),
                    if (loading && products.isEmpty)
                      const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (products.isEmpty)
                      HomeEmptyCatalogSliver(
                        loadFailed: failed,
                        onRefresh: catalog.load,
                        onReset: widget.browseController.resetDiscoveryOptions,
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        sliver: BuyerCatalogGrid(
                          products: products,
                          sale: true,
                          browseController: widget.browseController,
                          onProductTap: widget.onProductTap,
                        ),
                      ),
                    HomeCatalogFooter(
                      isLoadingMore: catalog.isLoadingMore,
                      hasMore: catalog.hasMore,
                      productCount: products.length,
                    ),
                    if (catalog.hasMore || catalog.error != null)
                      SliverToBoxAdapter(
                        child: Center(
                          child: TextButton(
                            onPressed: catalog.isLoadingMore || loading
                                ? null
                                : failed
                                ? catalog.load
                                : catalog.loadMore,
                            child: Text(
                              catalog.error != null
                                  ? 'Retry loading products'
                                  : 'Load more products',
                            ),
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}
