import 'dart:async';

import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/constants/agrisell_routes.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/products/data/home_product_repository.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/presentation/controllers/home_product_catalog_controller.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/common/buyer_responsive_text.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/product_detail/product_detail_action_bar.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/product_detail/product_detail_bottom_bar.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/product_detail/product_detail_info_card.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/product_detail/product_detail_recommendations_section.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/product_detail/product_detail_reviews.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/product_detail/product_image_header.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    required this.product,
    this.catalogController,
    this.productRepository = const HomeProductRepository(),
    super.key,
  });

  final HomeProduct product;
  final HomeProductCatalogController? catalogController;
  final HomeProductRepository productRepository;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _basketController = BasketController.instance;
  final _quantity = ValueNotifier<int>(1);
  final _showAddedFeedback = ValueNotifier<bool>(false);
  Timer? _addedFeedbackTimer;
  late final HomeProductCatalogController _catalogController;
  late final bool _ownsCatalogController;

  @override
  void initState() {
    super.initState();
    _ownsCatalogController = widget.catalogController == null;
    _catalogController =
        widget.catalogController ??
        HomeProductCatalogController(repository: widget.productRepository);
    if (_catalogController.status == HomeProductCatalogStatus.idle) {
      unawaited(_catalogController.load());
    }
  }

  void _addToBasket() {
    if (!widget.product.canOrder) {
      _showUnavailableMessage();
      return;
    }
    _basketController.addProduct(widget.product, quantity: _quantity.value);
    _showAddedFeedback.value = true;

    _addedFeedbackTimer?.cancel();
    _addedFeedbackTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) {
        _showAddedFeedback.value = false;
      }
    });
  }

  void _buyNow() {
    if (!widget.product.canOrder) {
      _showUnavailableMessage();
      return;
    }

    _basketController.addProduct(widget.product, quantity: _quantity.value);
    Navigator.of(context).pushNamed(AgrisellRoutes.checkout);
  }

  void _showUnavailableMessage() {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showAppSnackBar(
      SnackBar(
        content: Text('${widget.product.name} is not accepting orders now.'),
      ),
    );
  }

  void _incrementQuantity() {
    if (_quantity.value < 99) _quantity.value++;
  }

  void _decrementQuantity() {
    if (_quantity.value > 1) _quantity.value--;
  }

  void _openProduct(HomeProduct product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailScreen(
          product: product,
          catalogController: _catalogController,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _addedFeedbackTimer?.cancel();
    _quantity.dispose();
    _showAddedFeedback.dispose();
    if (_ownsCatalogController) _catalogController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final imageHeight = (width * 0.62).clamp(210.0, 285.0);
    return BuyerResponsiveText(
      child: Scaffold(
        backgroundColor: AgrisellColors.pageBackground,
        bottomNavigationBar: ValueListenableBuilder<bool>(
          valueListenable: _showAddedFeedback,
          builder: (context, showAddedFeedback, _) {
            return BottomActionBar(
              isAvailable: widget.product.canOrder,
              isPreOrder: widget.product.isPreOrder,
              onAddToBasket: _addToBasket,
              onBuyNow: _buyNow,
              showAddedFeedback: showAddedFeedback,
            );
          },
        ),
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _basketController,
                  builder: (context, _) {
                    return ProductDetailActionBar(
                      basketCount: _basketController.totalQuantity,
                      basketPulse: _basketController.pulse,
                    );
                  },
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverToBoxAdapter(
                  child: ProductImageHeader(
                    product: widget.product,
                    height: imageHeight,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                sliver: SliverToBoxAdapter(
                  child: ValueListenableBuilder<int>(
                    valueListenable: _quantity,
                    builder: (context, quantity, _) {
                      return ProductInfoCard(
                        key: const ValueKey('product-details-panel'),
                        product: widget.product,
                        quantity: quantity,
                        quantityEnabled: widget.product.canOrder,
                        onIncrement: _incrementQuantity,
                        onDecrement: _decrementQuantity,
                      );
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: ProductDetailReviews(product: widget.product),
                ),
              ),
              SliverToBoxAdapter(
                child: ProductDetailRecommendationsSection(
                  product: widget.product,
                  catalogController: _catalogController,
                  onProductSelected: _openProduct,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}
