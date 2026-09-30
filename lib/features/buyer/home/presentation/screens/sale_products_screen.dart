import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/home/presentation/screens/product_detail_screen.dart';
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
      MaterialPageRoute<void>(
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
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              sliver: SliverToBoxAdapter(
                child: TextField(
                  key: const ValueKey('sale-products-search'),
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search sale products',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: AgrisellColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              sliver: SliverToBoxAdapter(
                child: Text(
                  '${products.length} ${products.length == 1 ? 'product' : 'products'} on sale',
                  style: const TextStyle(
                    color: AgrisellColors.mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
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
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Text(
                      _loadFailed
                          ? 'Sale products could not be loaded. Pull down to try again.'
                          : 'No eligible sale products are available. The campaign may have ended.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AgrisellColors.mutedText,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: HomeProductGrid(
                  products: products,
                  onProductTap: _openProduct,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }
}
