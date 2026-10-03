import 'package:flutter/material.dart';

import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_empty_products.dart';

class HomeEmptyCatalogSliver extends StatelessWidget {
  const HomeEmptyCatalogSliver({
    required this.loadFailed,
    required this.onRefresh,
    required this.onReset,
    super.key,
  });

  final bool loadFailed;
  final RefreshCallback onRefresh;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: HomeEmptyProducts(
        onReset: loadFailed ? onRefresh : onReset,
        actionLabel:
            loadFailed ? 'Try again' : 'Reset search and filters',
        title:
            loadFailed ? 'Unable to load products' : 'No products available',
        message: loadFailed
            ? 'Check your connection and try again.'
            : 'No commodities have been posted yet. Pull down to refresh the marketplace.',
      ),
    );
  }
}
