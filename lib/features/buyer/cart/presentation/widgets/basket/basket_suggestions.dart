import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/features/buyer/cart/presentation/styles/basket_suggestions_styles.dart';
import 'package:agresell_app/features/buyer/cart/presentation/widgets/basket/basket_suggestion_grid.dart';
import 'package:agresell_app/features/buyer/cart/presentation/widgets/basket/basket_suggestion_label.dart';
import 'package:agresell_app/features/buyer/cart/presentation/widgets/basket/basket_suggestion_state_view.dart';
import 'package:agresell_app/features/shared/products/data/home_product_repository.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/presentation/controllers/home_product_catalog_controller.dart';

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
        HomeProductCatalogStatus.loading => const BasketSuggestionStateView(
          message: 'Loading product suggestions',
          isLoading: true,
        ),
        HomeProductCatalogStatus.error => BasketSuggestionStateView(
          message: 'Product suggestions are unavailable',
          actionLabel: 'Try again',
          onAction: _catalogController.load,
        ),
        HomeProductCatalogStatus.ready => _readyContent(),
      };
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BasketSuggestionLabel(),
          const SizedBox(height: BasketSuggestionsStyles.headerGap),
          content,
        ],
      );
    },
  );

  Widget _readyContent() {
    final suggestions = _suggestions();
    if (suggestions.isEmpty) {
      return const BasketSuggestionStateView(
        message: 'No other products available',
      );
    }
    return BasketSuggestionGrid(
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
