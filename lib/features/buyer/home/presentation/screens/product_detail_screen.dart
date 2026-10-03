import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/constants/agrisell_routes.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/buyer/home/presentation/styles/product_detail_styles.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/common/buyer_responsive_text.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/product_detail/product_detail_action_bar.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/product_detail/product_detail_bottom_bar.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/product_detail/product_detail_info_card.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/product_detail/product_detail_recommendations_section.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/product_detail/product_detail_reviews.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/product_detail/product_image_header.dart';
import 'package:agresell_app/features/shared/products/data/home_product_repository.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/presentation/controllers/home_product_catalog_controller.dart';

part 'product_detail_screen_actions.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    required this.product,
    this.catalogController,
    this.productRepository = const HomeProductRepository(),
    this.isSaved,
    this.onSavedToggle,
    super.key,
  });

  final HomeProduct product;
  final HomeProductCatalogController? catalogController;
  final HomeProductRepository productRepository;
  final bool Function(String productId)? isSaved;
  final ValueChanged<String>? onSavedToggle;

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
    final imageHeight = ProductDetailStyles.imageHeight(width);

    return BuyerResponsiveText(
      child: Scaffold(
        backgroundColor: ProductDetailStyles.backgroundColor,
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
                      productName: widget.product.name,
                      isSaved: widget.isSaved?.call(widget.product.id) ?? false,
                      onSavedToggle: widget.onSavedToggle == null
                          ? null
                          : () {
                              widget.onSavedToggle!(widget.product.id);
                              setState(() {});
                            },
                    );
                  },
                ),
              ),
              SliverPadding(
                padding: ProductDetailStyles.imagePadding,
                sliver: SliverToBoxAdapter(
                  child: ProductImageHeader(
                    product: widget.product,
                    height: imageHeight,
                  ),
                ),
              ),
              SliverPadding(
                padding: ProductDetailStyles.sectionPadding,
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
                  padding: ProductDetailStyles.sectionPadding,
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
              const SliverToBoxAdapter(
                child: SizedBox(height: ProductDetailStyles.bottomSpacerHeight),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
