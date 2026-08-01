import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/product_detail/product_detail_recommendations.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/presentation/controllers/home_product_catalog_controller.dart';

class ProductDetailRecommendationsSection extends StatelessWidget {
  const ProductDetailRecommendationsSection({
    required this.product,
    required this.catalogController,
    required this.onProductSelected,
    super.key,
  });

  final HomeProduct product;
  final HomeProductCatalogController catalogController;
  final ValueChanged<HomeProduct> onProductSelected;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: catalogController,
    builder: (context, _) {
      return switch (catalogController.status) {
        HomeProductCatalogStatus.idle ||
        HomeProductCatalogStatus.loading => const _RecommendationState(
          icon: Icons.sync_rounded,
          message: 'Loading recommendations',
          isLoading: true,
        ),
        HomeProductCatalogStatus.error => _RecommendationState(
          icon: Icons.cloud_off_rounded,
          message: 'Recommendations unavailable',
          actionLabel: 'Try again',
          onAction: catalogController.load,
        ),
        HomeProductCatalogStatus.ready => _readyContent(),
      };
    },
  );

  Widget _readyContent() {
    final recommendations = catalogController.products
        .where((candidate) => candidate.id != product.id)
        .take(5)
        .toList(growable: false);
    if (recommendations.isEmpty) {
      return const _RecommendationState(
        icon: Icons.inventory_2_outlined,
        message: 'No other products available',
      );
    }
    return ProductDetailRecommendations(
      products: recommendations,
      onProductSelected: onProductSelected,
    );
  }
}

class _RecommendationState extends StatelessWidget {
  const _RecommendationState({
    required this.icon,
    required this.message,
    this.isLoading = false,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final bool isLoading;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 18, 14, 0),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AgrisellColors.borderLine),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Row(
          children: [
            if (isLoading)
              const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(icon, color: AgrisellColors.authGreen, size: 22),
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
      ),
    ),
  );
}
