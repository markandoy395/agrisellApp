import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/shared/products/data/home_product_repository.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/presentation/controllers/home_product_catalog_controller.dart';
import 'package:agresell_app/features/buyer/home/presentation/controllers/home_product_browse_controller.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_product_scroll_view.dart';
import 'support/home_product_fixture.dart';

class _PaginatedProductRepository extends HomeProductRepository {
  _PaginatedProductRepository(this._allProducts);

  final List<HomeProduct> _allProducts;
  int fetchCalls = 0;

  @override
  Future<({List<HomeProduct> products, bool hasMore})> loadProductsPage({
    int limit = 24,
    int offset = 0,
  }) async {
    fetchCalls++;
    if (offset >= _allProducts.length) {
      return (products: const <HomeProduct>[], hasMore: false);
    }
    final end = (offset + limit).clamp(0, _allProducts.length);
    final slice = _allProducts.sublist(offset, end);
    return (products: slice, hasMore: end < _allProducts.length);
  }
}

void main() {
  group('HomeProductCatalogController Infinite Scrolling & Pagination', () {
    test('loads first chunk of products and sets hasMore', () async {
      final repo = _PaginatedProductRepository(testHomeProducts);
      final controller = HomeProductCatalogController(
        repository: repo,
        pageSize: 4,
      );
      addTearDown(controller.dispose);

      await controller.load();

      expect(controller.status, HomeProductCatalogStatus.ready);
      expect(controller.products.length, 4);
      expect(controller.hasMore, isTrue);
      expect(controller.isLoadingMore, isFalse);
      expect(repo.fetchCalls, 1);
    });

    test('loadMore appends the next chunk and deduplicates products', () async {
      final repo = _PaginatedProductRepository(testHomeProducts);
      final controller = HomeProductCatalogController(
        repository: repo,
        pageSize: 4,
      );
      addTearDown(controller.dispose);

      await controller.load();
      expect(controller.products.length, 4);

      await controller.loadMore();
      expect(controller.products.length, 8);
      expect(controller.hasMore, isTrue);
      expect(repo.fetchCalls, 2);

      // Verify no duplicate IDs
      final ids = controller.products.map((p) => p.id).toSet();
      expect(ids.length, 8);
    });

    test(
      'loadMore enforces concurrency lock preventing redundant calls',
      () async {
        final completer =
            Completer<({List<HomeProduct> products, bool hasMore})>();
        final repo = _AsyncPaginatedRepository(completer);
        final controller = HomeProductCatalogController(
          repository: repo,
          pageSize: 2,
        );
        addTearDown(controller.dispose);

        // Complete initial load
        await controller.load();
        expect(controller.products.length, 2);

        // Trigger loadMore but don't finish yet
        final firstLoadMore = controller.loadMore();
        expect(controller.isLoadingMore, isTrue);

        // Second trigger while first is still inflight should be ignored
        final secondLoadMore = controller.loadMore();
        expect(repo.pageCalls, 2); // 1 for initial load, 1 for firstLoadMore

        // Complete the inflight request
        completer.complete((
          products: [testHomeProducts[2], testHomeProducts[3]],
          hasMore: true,
        ));
        await firstLoadMore;
        await secondLoadMore;

        expect(controller.isLoadingMore, isFalse);
        expect(controller.products.length, 4);
        expect(repo.pageCalls, 2); // Didn't increment from the second trigger
      },
    );

    test('hasMore becomes false when reaching end of catalog', () async {
      final smallCatalog = testHomeProducts.take(3).toList();
      final repo = _PaginatedProductRepository(smallCatalog);
      final controller = HomeProductCatalogController(
        repository: repo,
        pageSize: 2,
      );
      addTearDown(controller.dispose);

      await controller.load();
      expect(controller.products.length, 2);
      expect(controller.hasMore, isTrue);

      await controller.loadMore();
      expect(controller.products.length, 3);
      expect(controller.hasMore, isFalse);

      // Subsequent loadMore does not make network calls when hasMore is false
      final callsBefore = repo.fetchCalls;
      await controller.loadMore();
      expect(repo.fetchCalls, callsBefore);
    });
  });

  group('HomeProductScrollView Infinite Scroll & UX', () {
    testWidgets('shows loading more indicator when isLoadingMore is true', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final bannerController = PageController();
      final searchController = TextEditingController();
      final browseController = HomeProductBrowseController();
      addTearDown(() {
        bannerController.dispose();
        searchController.dispose();
        browseController.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeProductScrollView(
              bannerController: bannerController,
              searchController: searchController,
              browseController: browseController,
              products: testHomeProducts.take(6).toList(),
              onBannerTap: (_) {},
              onViewAll: () {},
              onShowFilters: () {},
              onReset: () {},
              onProductTap: (_) {},
              onRefresh: () async {},
              isLoadingMore: true,
              hasMore: true,
            ),
          ),
        ),
      );
      await tester.pump();

      // Scroll down to view the bottom adapter
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pump();

      expect(find.text('Loading more products...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
      'triggers onLoadMore when scrolled near the bottom (80% depth)',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 932));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final bannerController = PageController();
        final searchController = TextEditingController();
        final browseController = HomeProductBrowseController();
        addTearDown(() {
          bannerController.dispose();
          searchController.dispose();
          browseController.dispose();
        });

        var loadMoreTriggered = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HomeProductScrollView(
                bannerController: bannerController,
                searchController: searchController,
                browseController: browseController,
                products: testHomeProducts.take(8).toList(),
                onBannerTap: (_) {},
                onViewAll: () {},
                onShowFilters: () {},
                onReset: () {},
                onProductTap: (_) {},
                onRefresh: () async {},
                isLoadingMore: false,
                hasMore: true,
                onLoadMore: () {
                  loadMoreTriggered = true;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.drag(
          find.byType(CustomScrollView),
          const Offset(-1000, 0),
        );
        await tester.pumpAndSettle();
        expect(loadMoreTriggered, isFalse);

        // Scroll the combined catalog to its end.
        final scroll = tester.state<ScrollableState>(
          find
              .descendant(
                of: find.byType(CustomScrollView),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        scroll.position.jumpTo(scroll.position.maxScrollExtent);
        await tester.pumpAndSettle();

        expect(loadMoreTriggered, isTrue);
      },
    );
  });
}

class _AsyncPaginatedRepository extends HomeProductRepository {
  _AsyncPaginatedRepository(this._completer);

  final Completer<({List<HomeProduct> products, bool hasMore})> _completer;
  int pageCalls = 0;

  @override
  Future<({List<HomeProduct> products, bool hasMore})> loadProductsPage({
    int limit = 24,
    int offset = 0,
  }) async {
    pageCalls++;
    if (pageCalls == 1) {
      return (
        products: [testHomeProducts[0], testHomeProducts[1]],
        hasMore: true,
      );
    }
    return _completer.future;
  }
}
