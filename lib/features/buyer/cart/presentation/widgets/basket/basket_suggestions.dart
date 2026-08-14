import 'dart:async';

import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/products/data/home_product_repository.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/presentation/controllers/home_product_catalog_controller.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/product_thumbnail.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/buyer/home/presentation/screens/product_detail_screen.dart';

class BasketSuggestions extends StatefulWidget {
  const BasketSuggestions({
    required this.excludedProductIds,
    this.catalogController,
    this.productRepository = const HomeProductRepository(),
    super.key,
  });

  final Set<String> excludedProductIds;
  final HomeProductCatalogController? catalogController;
  final HomeProductRepository productRepository;

  @override
  State<BasketSuggestions> createState() => _BasketSuggestionsState();
}

class _BasketSuggestionsState extends State<BasketSuggestions> {
  static const _suggestionLimit = 10;
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
    if (_ownsCatalogController) _catalogController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _catalogController,
    builder: (context, _) {
      final content = switch (_catalogController.status) {
        HomeProductCatalogStatus.idle ||
        HomeProductCatalogStatus.loading => const _SuggestionState(
          message: 'Loading product suggestions',
          isLoading: true,
        ),
        HomeProductCatalogStatus.error => _SuggestionState(
          message: 'Product suggestions are unavailable',
          actionLabel: 'Try again',
          onAction: _catalogController.load,
        ),
        HomeProductCatalogStatus.ready => _readyContent(),
      };
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SuggestionLabel(),
          const SizedBox(height: 12),
          content,
        ],
      );
    },
  );

  Widget _readyContent() {
    final suggestions = _suggestions();
    if (suggestions.isEmpty) {
      return const _SuggestionState(message: 'No other products available');
    }
    return _SuggestionGrid(
      suggestions: suggestions,
      catalogController: _catalogController,
    );
  }

  List<HomeProduct> _suggestions() {
    final products = _catalogController.products
        .where((product) => !widget.excludedProductIds.contains(product.id))
        .take(_suggestionLimit)
        .toList();
    if (products.isNotEmpty) {
      return products;
    }
    return _catalogController.products.take(_suggestionLimit).toList();
  }
}

class _SuggestionGrid extends StatelessWidget {
  const _SuggestionGrid({
    required this.suggestions,
    required this.catalogController,
  });
  final List<HomeProduct> suggestions;
  final HomeProductCatalogController catalogController;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = screenWidth < 380 ? 154.0 : 166.0;

    return SizedBox(
      height: 226,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) => SizedBox(
          width: cardWidth,
          child: _SuggestionCard(
            product: suggestions[index],
            catalogController: catalogController,
          ),
        ),
      ),
    );
  }
}

class _SuggestionLabel extends StatelessWidget {
  const _SuggestionLabel();
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AgrisellColors.forestSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.eco_outlined,
            color: AgrisellColors.authGreen,
            size: 21,
          ),
        ),
        const SizedBox(width: 11),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You may also like',
                style: TextStyle(
                  color: AgrisellColors.headingGreen,
                  fontSize: 15,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'More fresh picks from local farmers',
                style: TextStyle(
                  color: AgrisellColors.mutedText,
                  fontSize: 12,
                  height: 1.2,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 7),
          child: Icon(
            Icons.swipe_left_rounded,
            color: AgrisellColors.mutedText,
            size: 20,
          ),
        ),
      ],
    );
  }
}

class _SuggestionState extends StatelessWidget {
  const _SuggestionState({
    required this.message,
    this.isLoading = false,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final bool isLoading;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    decoration: BoxDecoration(
      color: AgrisellColors.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AgrisellColors.borderLine),
    ),
    child: Row(
      children: [
        if (isLoading)
          const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          const Icon(
            Icons.inventory_2_outlined,
            color: AgrisellColors.authGreen,
            size: 21,
          ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: AgrisellColors.headingGreen,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    ),
  );
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.product,
    required this.catalogController,
  });
  final HomeProduct product;
  final HomeProductCatalogController catalogController;
  @override
  Widget build(BuildContext context) {
    final canAddToBasket = product.canOrder;
    final radius = BorderRadius.circular(16);

    return Semantics(
      button: true,
      label: 'View ${product.name}',
      child: Material(
        color: AgrisellColors.surface,
        borderRadius: radius,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: radius,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ProductDetailScreen(
                  product: product,
                  catalogController: catalogController,
                ),
              ),
            );
          },
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: AgrisellColors.borderLine),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 126,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(
                        color: AgrisellColors.searchBackground,
                        child: ProductThumbnail(
                          asset: product.image,
                          imageUrl: product.imageUrl,
                          width: double.infinity,
                          height: 126,
                          borderRadius: 0,
                          semanticLabel: '${product.name} product photo',
                          filterQuality: FilterQuality.medium,
                          gaplessPlayback: true,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Material(
                          color: AgrisellColors.surface.withValues(alpha: 0.94),
                          shape: const CircleBorder(),
                          elevation: 1,
                          child: IconButton(
                            tooltip: canAddToBasket
                                ? 'Add ${product.name} to basket'
                                : 'Product unavailable',
                            constraints: const BoxConstraints.tightFor(
                              width: 34,
                              height: 34,
                            ),
                            padding: EdgeInsets.zero,
                            onPressed: canAddToBasket
                                ? () => _addToBasket(context)
                                : null,
                            icon: Icon(
                              canAddToBasket
                                  ? Icons.add_shopping_cart_rounded
                                  : Icons.block_rounded,
                              size: 17,
                              color: canAddToBasket
                                  ? AgrisellColors.authGreen
                                  : AgrisellColors.mutedText,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AgrisellColors.headingGreen,
                            fontSize: 13,
                            height: 1.15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          product.sellerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AgrisellColors.mutedText,
                            fontSize: 11,
                            height: 1.15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${product.price} ${product.unit}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AgrisellColors.authGreen,
                            fontSize: 12,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addToBasket(BuildContext context) {
    BasketController.instance.addProduct(product);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showAppSnackBar(
        SnackBar(content: Text('${product.name} added to your basket.')),
      );
  }
}
