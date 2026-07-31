part of 'package:agresell_app/features/farmer/dashboard/presentation/screens/farmer_dashboard_screen.dart';

class _FarmerProductCard extends StatelessWidget {
  const _FarmerProductCard({required this.product, required this.onEdit});

  final FarmerDashboardProduct product;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: radius,
        border: Border.all(color: AgrisellColors.borderLine),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                  aspectRatio: 1.24,
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
                      Positioned(
                        left: 10,
                        bottom: 10,
                        child: _ProductCategoryTag(label: product.category),
                      ),
                      Positioned(
                        top: 9,
                        right: 9,
                        child: _EditProductButton(
                          productName: product.name,
                          onTap: onEdit,
                        ),
                      ),
                      if (product.isSold) const FarmerSoldStatusOverlay(),
                    ],
                  ),
                ),
                Expanded(child: _FarmerProductDetails(product: product)),
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
    decoration: BoxDecoration(
      color: AgrisellColors.surface.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AgrisellColors.headingGreen,
          fontSize: 12,
          height: 1,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}
