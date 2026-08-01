import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/buyer/home/presentation/controllers/home_product_browse_controller.dart';
import 'package:agresell_app/features/buyer/home/presentation/screens/product_detail_screen.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_banner_carousel.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/home_categories_card.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_entrance_animation.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_header.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_empty_products.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_pinned_search_header.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_product_results_header.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/home_product_grid.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/home_product_grid_skeleton.dart';

class HomeProductScrollView extends StatelessWidget {
  const HomeProductScrollView({
    required this.bannerController,
    required this.searchController,
    required this.browseController,
    required this.products,
    required this.onShowFilters,
    required this.onReset,
    required this.onAddToBasket,
    required this.onRefresh,
    this.loadFailed = false,
    this.isLoading = false,
    super.key,
  });

  final PageController bannerController;
  final TextEditingController searchController;
  final HomeProductBrowseController browseController;
  final List<HomeProduct> products;
  final VoidCallback onShowFilters;
  final VoidCallback onReset;
  final ValueChanged<HomeProduct> onAddToBasket;
  final RefreshCallback onRefresh;
  final bool loadFailed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width < 380 ? 18.0 : 24.0;
    final contentPadding = width < 380 ? 10.0 : 14.0;
    final sectionGap = width < 380 ? 18.0 : 24.0;
    final contentGap = width < 380 ? 16.0 : 20.0;
    final bannerHeight = (width * 0.48).clamp(164.0, 220.0);

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: AgrisellColors.authGreen,
        onRefresh: onRefresh,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  20,
                  horizontalPadding,
                  0,
                ),
                child: HomeEntranceAnimation(child: const HomeHeader()),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: sectionGap)),
            SliverPersistentHeader(
              pinned: true,
              delegate: HomePinnedSearchHeaderDelegate(
                horizontalPadding: horizontalPadding,
                bottomGap: width < 380 ? 10 : 12,
                searchController: searchController,
                activeFilterCount: browseController.activeFilterCount,
                onQueryChanged: browseController.updateQuery,
                onFilterTap: onShowFilters,
              ),
            ),
            SliverToBoxAdapter(
              child: HomeBannerCarousel(
                controller: bannerController,
                height: bannerHeight,
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: contentGap)),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: contentPadding),
              sliver: SliverToBoxAdapter(
                child: HomeCategoriesCard(
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
                  onReset: onReset,
                  title: loadFailed
                      ? 'Unable to load products'
                      : 'No products available',
                  message: loadFailed
                      ? 'Pull down to try again.'
                      : 'No commodities have been posted yet. Pull down to refresh the marketplace.',
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: contentPadding),
                sliver: HomeProductGrid(
                  products: products,
                  isSaved: browseController.isSaved,
                  onSavedToggle: (product) =>
                      browseController.toggleSaved(product.id),
                  onAddToBasket: onAddToBasket,
                  onProductTap: (product) => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 112)),
          ],
        ),
      ),
    );
  }
}
