import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/buyer/home/presentation/controllers/home_product_browse_controller.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_banner_carousel.dart';
import 'package:agresell_app/features/buyer/home/domain/home_banner.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/buyer_home_categories.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_entrance_animation.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_header.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_empty_products.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_pinned_search_header.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_product_results_header.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_sale_products_section.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/home_product_grid.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/home_product_grid_skeleton.dart';

class HomeProductScrollView extends StatelessWidget {
  const HomeProductScrollView({
    required this.bannerController,
    required this.searchController,
    required this.browseController,
    required this.products,
    required this.saleProducts,
    required this.onBannerTap,
    required this.onViewAllSales,
    required this.onShowFilters,
    required this.onReset,
    required this.onProductTap,
    required this.onRefresh,
    this.onOpenDeals,
    this.loadFailed = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.onLoadMore,
    super.key,
  });

  final PageController bannerController;
  final TextEditingController searchController;
  final HomeProductBrowseController browseController;
  final List<HomeProduct> products;
  final List<HomeProduct> saleProducts;
  final ValueChanged<HomeBanner> onBannerTap;
  final VoidCallback onViewAllSales;
  final VoidCallback onShowFilters;
  final VoidCallback onReset;
  final ValueChanged<HomeProduct> onProductTap;
  final RefreshCallback onRefresh;
  final VoidCallback? onOpenDeals;
  final VoidCallback? onLoadMore;
  final bool loadFailed;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width < 380 ? 12.0 : 16.0;
    final contentPadding = width < 380 ? 12.0 : 14.0;
    final contentGap = width < 380 ? 12.0 : 16.0;
    final bannerHeight = (width * 0.44).clamp(168.0, 196.0);

    return RefreshIndicator(
      color: AgrisellColors.authGreen,
      onRefresh: onRefresh,
      child: SafeArea(
        bottom: false,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            final maxScroll = notification.metrics.maxScrollExtent;
            final pixels = notification.metrics.pixels;
            if (maxScroll > 0) {
              final scrollDepth = pixels / maxScroll;
              if (scrollDepth >= 0.80) {
                onLoadMore?.call();
              }
            }
            return false;
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
            SliverToBoxAdapter(
              child: HomeEntranceAnimation(
                child: HomeHeader(horizontalPadding: horizontalPadding),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: HomePinnedSearchHeaderDelegate(
                horizontalPadding: horizontalPadding,
                bottomGap: width < 380 ? 10 : 12,
                searchController: searchController,
                activeFilterCount: browseController.activeFilterCount,
                searchSuggestions: products
                    .map((product) => product.name)
                    .toSet()
                    .take(8)
                    .toList(growable: false),
                onQueryChanged: browseController.updateQuery,
                onFilterTap: onShowFilters,
              ),
            ),
            SliverToBoxAdapter(
              child: HomeBannerCarousel(
                controller: bannerController,
                height: bannerHeight,
                onBannerTap: onBannerTap,
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: contentGap)),
            if (onOpenDeals != null) ...[
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: contentPadding),
                sliver: SliverToBoxAdapter(
                  child: _HomeDealsQuickBanner(onTap: onOpenDeals),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: contentGap)),
            ],
            if (saleProducts.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: HomeSaleProductsSection(
                  products: saleProducts,
                  onViewAll: onViewAllSales,
                  onProductTap: onProductTap,
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: contentGap)),
            ],
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: contentPadding),
              sliver: SliverToBoxAdapter(
                child: BuyerHomeCategories(
                  selectedCategory: browseController.selectedCategory,
                  onSelected: browseController.selectCategory,
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                contentPadding,
                contentGap,
                contentPadding,
                12,
              ),
              sliver: SliverToBoxAdapter(
                child: HomeProductResultsHeader(
                  resultCount: products.length,
                  savedCount: browseController.savedCount,
                  savedOnly: browseController.savedOnly,
                  sort: browseController.sort,
                  onSavedOnlyChanged: browseController.setSavedOnly,
                  onSortChanged: browseController.setSort,
                ),
              ),
            ),
            if (isLoading)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: contentPadding),
                sliver: const HomeProductGridSkeleton(),
              )
            else if (products.isEmpty)
              SliverToBoxAdapter(
                child: HomeEmptyProducts(
                  onReset: loadFailed ? onRefresh : onReset,
                  actionLabel: loadFailed
                      ? 'Try again'
                      : 'Reset search and filters',
                  title: loadFailed
                      ? 'Unable to load products'
                      : 'No products available',
                  message: loadFailed
                      ? 'Check your connection and try again.'
                      : 'No commodities have been posted yet. Pull down to refresh the marketplace.',
                ),
              )
            else ...[
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: contentPadding),
                sliver: HomeProductGrid(
                  products: products,
                  onProductTap: onProductTap,
                ),
              ),
              if (isLoadingMore)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: AgrisellColors.authGreen,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Loading more products...',
                            style: TextStyle(
                              fontSize: 12,
                              color: AgrisellColors.brandBlack.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (!hasMore && products.length >= 10)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'You’ve reached the end of the catalog',
                        style: TextStyle(
                          fontSize: 12,
                          color: AgrisellColors.brandBlack.withValues(alpha: 0.45),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 112)),
          ],
        ),
        ),
      ),
    );
  }
}

class _HomeDealsQuickBanner extends StatelessWidget {
  const _HomeDealsQuickBanner({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AgrisellColors.brandBlack.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_offer_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deals & Voucher Wallet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Browse active promos, vouchers & limited discounts',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white70,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
