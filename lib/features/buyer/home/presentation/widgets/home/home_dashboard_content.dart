import 'dart:async';

import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/constants/agrisellRoutes.dart';
import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/shared/products/data/home_product_repository.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/buyer/home/presentation/controllers/home_product_browse_controller.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_product_filter_sheet.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_product_scroll_view.dart';

class HomeDashboardContent extends StatefulWidget {
  const HomeDashboardContent({
    this.productRepository = const HomeProductRepository(),
    super.key,
  });

  final HomeProductRepository productRepository;

  @override
  State<HomeDashboardContent> createState() => _HomeDashboardContentState();
}

class _HomeDashboardContentState extends State<HomeDashboardContent> {
  late final TextEditingController _searchController;
  late final PageController _bannerController;
  late final HomeProductBrowseController _browseController;
  List<HomeProduct> _products = const [];
  bool _isLoading = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _bannerController = PageController(initialPage: 1, viewportFraction: 0.78);
    _browseController = HomeProductBrowseController();
    unawaited(_loadProducts());
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

  Future<void> _loadProducts() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadFailed = false;
      });
    }
    try {
      final products = await widget.productRepository.loadProducts();
      if (!mounted) return;
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } on Object {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadFailed = true;
        });
      }
    }
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
      animation: _browseController,
      builder: (context, _) {
        return HomeProductScrollView(
          bannerController: _bannerController,
          searchController: _searchController,
          browseController: _browseController,
          products: _browseController.visibleProducts(_products),
          isLoading: _isLoading,
          loadFailed: _loadFailed,
          onRefresh: _loadProducts,
          onShowFilters: _showFilters,
          onReset: _resetDiscovery,
          onAddToBasket: _addToBasket,
        );
      },
    );
  }
}
