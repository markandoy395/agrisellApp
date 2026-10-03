import 'package:flutter/material.dart';

import 'package:agresell_app/features/buyer/home/presentation/styles/sale_products_styles.dart';

class SaleProductsSearchSliver extends StatelessWidget {
  const SaleProductsSearchSliver({
    required this.controller,
    super.key,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: SaleProductsStyles.searchFieldPadding,
    sliver: SliverToBoxAdapter(
      child: TextField(
        key: const ValueKey('sale-products-search'),
        controller: controller,
        decoration: SaleProductsStyles.searchDecoration,
      ),
    ),
  );
}

class SaleProductsCountSliver extends StatelessWidget {
  const SaleProductsCountSliver({
    required this.count,
    super.key,
  });

  final int count;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: SaleProductsStyles.countLabelPadding,
    sliver: SliverToBoxAdapter(
      child: Text(
        '$count ${count == 1 ? 'product' : 'products'} on sale',
        style: SaleProductsStyles.countLabelStyle,
      ),
    ),
  );
}

class SaleProductsEmptySliver extends StatelessWidget {
  const SaleProductsEmptySliver({
    required this.loadFailed,
    super.key,
  });

  final bool loadFailed;

  @override
  Widget build(BuildContext context) => SliverFillRemaining(
    hasScrollBody: false,
    child: Center(
      child: Padding(
        padding: SaleProductsStyles.emptyPadding,
        child: Text(
          loadFailed
              ? 'Sale products could not be loaded. Pull down to try again.'
              : 'No eligible sale products are available. The campaign may have ended.',
          textAlign: TextAlign.center,
          style: SaleProductsStyles.emptyMessageStyle,
        ),
      ),
    ),
  );
}
