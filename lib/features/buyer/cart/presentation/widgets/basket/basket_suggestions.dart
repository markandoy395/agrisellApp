import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/core/widgets/responsiveAssetImage.dart';
import 'package:agresell_app/features/shared/products/data/home_products.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/buyer/home/presentation/screens/product_detail_screen.dart';

class BasketSuggestions extends StatelessWidget {
  const BasketSuggestions({required this.excludedProductIds, super.key});
  static const _suggestionLimit = 10;
  final Set<String> excludedProductIds;
  @override
  Widget build(BuildContext context) {
    final suggestions = _suggestions();
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SuggestionLabel(),
        const SizedBox(height: 10),
        _SuggestionGrid(suggestions: suggestions),
      ],
    );
  }

  List<HomeProduct> _suggestions() {
    final products = homeProducts
        .where((product) => !excludedProductIds.contains(product.id))
        .take(_suggestionLimit)
        .toList();
    if (products.isNotEmpty) {
      return products;
    }
    return homeProducts.take(_suggestionLimit).toList();
  }
}

class _SuggestionGrid extends StatelessWidget {
  const _SuggestionGrid({required this.suggestions});
  static const _gap = 10.0;
  final List<HomeProduct> suggestions;
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
                child: _SuggestionCard(product: product),
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

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.product});
  final HomeProduct product;
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
                builder: (_) => ProductDetailScreen(product: product),
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
