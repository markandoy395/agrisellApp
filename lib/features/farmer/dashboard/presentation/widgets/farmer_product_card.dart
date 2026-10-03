part of 'package:agresell_app/features/farmer/dashboard/presentation/screens/farmer_dashboard_screen.dart';

class _FarmerProductCard extends StatelessWidget {
  const _FarmerProductCard({
    required this.product,
    required this.onEdit,
    required this.onRestock,
    required this.isRestocking,
  });

  final FarmerDashboardProduct product;
  final VoidCallback onEdit;
  final VoidCallback onRestock;
  final bool isRestocking;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10);

    return DecoratedBox(
      decoration: FarmerProductCardStyles.decoratedBoxDecoration(radius),
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          color: AgrisellColors.surface,
          child: InkWell(
            onTap: onEdit,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 1.55,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ResponsiveAssetImage(
                        asset: product.imageAsset,
                        imageBytes: product.imageBytes,
                        imageUrl: product.imageUrl,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        semanticLabel: '${product.name} product photo',
                      ),
                      if (product.isInActiveSale)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: _FarmerSaleBadge(
                            label: product.activeSaleDiscount ?? 'SALE',
                          ),
                        ),
                      Positioned(
                        left: 8,
                        bottom: 8,
                        child: _ProductCategoryTag(label: product.category),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: _EditProductButton(
                          productName: product.name,
                          onTap: onEdit,
                        ),
                      ),
                      if (product.isSold) const FarmerSoldStatusOverlay(),
                    ],
                  ),
                ),
                Expanded(
                  child: _FarmerProductDetails(
                    product: product,
                    onRestock: onRestock,
                    isRestocking: isRestocking,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductCategoryTag extends StatelessWidget {
  const _ProductCategoryTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: FarmerProductCardStyles.decoratedBoxDecoration2,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: FarmerProductCardStyles.labelText,
      ),
    ),
  );
}

class _FarmerSaleBadge extends StatelessWidget {
  const _FarmerSaleBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: FarmerProductCardStyles.decoratedBoxDecoration3,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_offer_rounded, color: Colors.white, size: 11),
          const SizedBox(width: 4),
          Text(label, style: FarmerProductCardStyles.labelText2),
        ],
      ),
    ),
  );
}
