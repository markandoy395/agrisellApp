import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/home/domain/home_banner.dart';
import 'package:agresell_app/features/buyer/home/presentation/controllers/home_product_browse_controller.dart';
import 'package:agresell_app/features/buyer/home/presentation/styles/home_product_scroll_view_styles.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/buyer_home_categories.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_banner_carousel.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_catalog_footer.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_catalog_pagination.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_catalog_status.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_deals_quick_banner.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_empty_catalog_sliver.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_entrance_animation.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_header.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_pinned_search_header.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_product_results_header.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import '../catalog/buyer_catalog_grid.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/home_product_grid_skeleton.dart';

class HomeProductScrollView extends StatelessWidget {
  const HomeProductScrollView({
    required this.bannerController,
    required this.searchController,
    required this.browseController,
    required this.products,
    required this.onBannerTap,
    required this.onViewAll,
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
  final ValueChanged<HomeBanner> onBannerTap;
  final VoidCallback onViewAll;
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
    final horizontalPadding = HomeProductScrollViewStyles.horizontalPadding(
      width,
    );
    final contentPadding = HomeProductScrollViewStyles.contentPadding(width);
    final contentGap = HomeProductScrollViewStyles.contentGap(width);
    final bannerHeight = HomeProductScrollViewStyles.bannerHeight(width);

    return RefreshIndicator(
      color: AgrisellColors.authGreen,
      onRefresh: onRefresh,
      child: SafeArea(
        bottom: false,
        child: HomeCatalogPagination(
          enabled: !isLoadingMore && hasMore && !isLoading && !loadFailed,
          onLoadMore: onLoadMore,
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
                  bottomGap: HomeProductScrollViewStyles.searchBottomGap(width),
                  searchController: searchController,
                  activeFilterCount: browseController.activeFilterCount,
                  searchSuggestions:
                      HomeProductScrollViewStyles.searchSuggestions(products),
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
                    child: HomeDealsQuickBanner(onTap: onOpenDeals),
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
                padding: HomeProductScrollViewStyles.resultsHeaderPadding(
                  contentPadding,
                  contentGap,
                ),
                sliver: SliverToBoxAdapter(
                  child: HomeProductResultsHeader(
                    onViewAll: onViewAll,
                    resultCount: products.length,
                    savedCount: browseController.savedCount,
                    savedOnly: browseController.savedOnly,
                    sort: browseController.sort,
                    onSavedOnlyChanged: browseController.setSavedOnly,
                    onSortChanged: browseController.setSort,
                  ),
                ),
              ),
              if (products.isNotEmpty && (isLoading || loadFailed))
                HomeCatalogStatus(failed: loadFailed),
              if (isLoading && products.isEmpty)
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: contentPadding),
                  sliver: const HomeProductGridSkeleton(),
                )
              else if (products.isEmpty)
                HomeEmptyCatalogSliver(
                  loadFailed: loadFailed,
                  onRefresh: onRefresh,
                  onReset: onReset,
                )
              else ...[
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: contentPadding),
                  sliver: BuyerCatalogGrid(
                    products: products,
                    browseController: browseController,
                    sale: true,
                    onProductTap: onProductTap,
                  ),
                ),
                HomeCatalogFooter(
                  isLoadingMore: isLoadingMore,
                  hasMore: hasMore,
                  productCount: products.length,
                ),
              ],
              const HomeCatalogBottomSpacer(),
            ],
          ),
        ),
      ),
    );
  }
}
