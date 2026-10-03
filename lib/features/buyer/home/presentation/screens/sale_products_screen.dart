import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/home/presentation/screens/product_detail_screen.dart';
import 'package:agresell_app/features/buyer/home/presentation/styles/sale_products_styles.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/sale_products_slivers.dart';
import 'package:agresell_app/features/shared/products/data/home_product_repository.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/home_product_grid.dart';

class SaleProductsScreen extends StatefulWidget {
  const SaleProductsScreen({
    required this.title,
    this.campaignSaleId,
    this.initialProducts,
    this.productRepository = const HomeProductRepository(),
    super.key,
  }) : assert(campaignSaleId != null || initialProducts != null);

  final String title;
  final int? campaignSaleId;
  final List<HomeProduct>? initialProducts;
  final HomeProductRepository productRepository;

  @override
  State<SaleProductsScreen> createState() => _SaleProductsScreenState();
}

class _SaleProductsScreenState extends State<SaleProductsScreen> {
  late final TextEditingController _searchController;
  List<HomeProduct> _products = const [];
  var _isLoading = false;
  var _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController()..addListener(_refreshSearch);
    final initialProducts = widget.initialProducts;
    if (initialProducts != null) {
      _products = initialProducts
          .where((product) => product.hasSale)
          .toList(growable: false);
    } else {
      unawaited(_loadCampaignProducts());
    }
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_refreshSearch)
      ..dispose();
    super.dispose();
  }

  List<HomeProduct> get _visibleProducts {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _products;
    return _products
        .where(
          (product) =>
              product.name.toLowerCase().contains(query) ||
              product.category.toLowerCase().contains(query) ||
              product.sellerName.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  void _refreshSearch() => setState(() {});

  Future<void> _loadCampaignProducts() async {
    final saleId = widget.campaignSaleId;
    if (saleId == null) return;
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });
    try {
      final products = await widget.productRepository.loadSaleCampaignProducts(
        saleId: saleId,
      );
      if (!mounted) return;
      setState(
        () => _products = products
            .where((product) => product.hasSale)
            .toList(growable: false),
      );
    } on Object {
      if (!mounted) return;
      setState(() => _loadFailed = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openProduct(HomeProduct product) {
    Navigator.of(context).push(
      agrisellMaterialPageRoute<void>(
        builder: (_) => ProductDetailScreen(
          product: product,
          productRepository: widget.productRepository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = _visibleProducts;
    return Scaffold(
      backgroundColor: AgrisellColors.homeBackground,
      appBar: AppBar(
        backgroundColor: AgrisellColors.authGreen,
        foregroundColor: AgrisellColors.surface,
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: SaleProductsStyles.appBarTitleStyle,
        ),
      ),
      body: RefreshIndicator(
        color: AgrisellColors.authGreen,
        onRefresh: widget.campaignSaleId == null
            ? () async {}
            : _loadCampaignProducts,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SaleProductsSearchSliver(controller: _searchController),
            SaleProductsCountSliver(count: products.length),
            if (_isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AgrisellColors.authGreen,
                  ),
                ),
              )
            else if (products.isEmpty)
              SaleProductsEmptySliver(loadFailed: _loadFailed)
            else
              SliverPadding(
                padding: SaleProductsStyles.gridPadding,
                sliver: HomeProductGrid(
                  products: products,
                  onProductTap: _openProduct,
                ),
              ),
            const SliverToBoxAdapter(child: SaleProductsStyles.bottomSpacer),
          ],
        ),
      ),
    );
  }
}
