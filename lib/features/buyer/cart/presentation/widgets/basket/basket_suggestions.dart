import 'dart:async';

import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/core/widgets/responsiveAssetImage.dart';
import 'package:agresell_app/features/shared/products/data/home_product_repository.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/presentation/controllers/home_product_catalog_controller.dart';
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
          const SizedBox(height: 10),
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
  static const _gap = 10.0;
  final List<HomeProduct> suggestions;
  final HomeProductCatalogController catalogController;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fallbackWidth = MediaQuery.sizeOf(context).width;
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : fallbackWidth;
        final columnCount = availableWidth < 250 ? 1 : 2;
        final tileWidth =
            (availableWidth - _gap * (columnCount - 1)) / columnCount;
        final tileHeight = tileWidth / 1.05;
        return Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: [
            for (final product in suggestions)
              SizedBox(
                width: tileWidth,
                height: tileHeight,
                child: _SuggestionCard(
                  product: product,
                  catalogController: catalogController,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SuggestionLabel extends StatelessWidget {
  const _SuggestionLabel();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.24),
            thickness: 1,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Check other products',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AgrisellColors.brandBlack,
              fontSize: 12,
              height: 1,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.24),
            thickness: 1,
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
    return Semantics(
      button: true,
      label: 'View ${product.name}',
      child: Material(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(8),
        elevation: 3,
        shadowColor: AgrisellColors.brandBlack.withValues(alpha: 0.16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              ResponsiveAssetImage(
                asset: product.image,
                fit: BoxFit.cover,
                semanticLabel: '${product.name} product photo',
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: AgrisellColors.surface,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: IconButton(
                    tooltip: product.isAvailable
                        ? 'Add ${product.name} to basket'
                        : 'Product unavailable',
                    constraints: const BoxConstraints.tightFor(
                      width: 36,
                      height: 36,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: product.isAvailable
                        ? () {
                            BasketController.instance.addProduct(product);
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showAppSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${product.name} added to your basket.',
                                  ),
                                ),
                              );
                          }
                        : null,
                    icon: Icon(
                      product.isAvailable
                          ? Icons.add_shopping_cart_rounded
                          : Icons.block_rounded,
                      size: 18,
                      color: product.isAvailable
                          ? AgrisellColors.authGreen
                          : AgrisellColors.mutedText,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AgrisellColors.brandBlack.withValues(alpha: 0.48),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
                    child: Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AgrisellColors.surface,
                        fontSize: 12,
                        height: 1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
