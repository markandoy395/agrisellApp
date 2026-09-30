import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer_shop/farmer_product_card.dart';

class FarmerProductGrid extends StatelessWidget {
  const FarmerProductGrid({
    required this.products,
    required this.isLoading,
    required this.loadFailed,
    required this.onRetry,
    required this.onProductTap,
    super.key,
  });

  final List<HomeProduct> products;
  final bool isLoading;
  final bool loadFailed;
  final VoidCallback onRetry;
  final ValueChanged<HomeProduct> onProductTap;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (products.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _ProductStatusCard(loadFailed: loadFailed, onRetry: onRetry),
      );
    }

    return SliverGrid.builder(
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: FarmerProductCard.cardHeight,
      ),
      itemBuilder: (context, index) {
        final product = products[index];

        return FarmerProductCard(
          product: product,
          onTap: () => onProductTap(product),
        );
      },
    );
  }
}

class _ProductStatusCard extends StatelessWidget {
  const _ProductStatusCard({required this.loadFailed, required this.onRetry});

  final bool loadFailed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
        decoration: BoxDecoration(
          color: AgrisellColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AgrisellColors.borderLine),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              loadFailed ? Icons.cloud_off_rounded : Icons.eco_outlined,
              size: 34,
              color: AgrisellColors.authGreen,
            ),
            const SizedBox(height: 10),
            Text(
              loadFailed ? 'Couldn\'t load products' : 'No produce listed yet',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AgrisellColors.headingGreen,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              loadFailed
                  ? 'Check the connection or product access, then try again.'
                  : 'This farmer has not published any products for buyers yet.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AgrisellColors.mutedText,
                fontSize: 12,
                height: 1.3,
              ),
            ),
            if (loadFailed) ...[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Try again'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AgrisellColors.authGreen,
                  minimumSize: const Size(112, 38),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
