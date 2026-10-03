part of 'package:agresell_app/features/farmer/dashboard/presentation/screens/farmer_dashboard_screen.dart';

class _FarmerProductDetails extends StatelessWidget {
  const _FarmerProductDetails({
    required this.product,
    required this.onRestock,
    required this.isRestocking,
  });

  final FarmerDashboardProduct product;
  final VoidCallback onRestock;
  final bool isRestocking;

  @override
  Widget build(BuildContext context) {
    final valueColor = product.isSold
        ? AgrisellColors.mutedText
        : AgrisellColors.authGreen;
    final nameColor = product.isSold
        ? AgrisellColors.brandBlack.withValues(alpha: 0.72)
        : AgrisellColors.brandBlack;
    final unit = product.unit.trim();
    final unitLabel = unit.toLowerCase().startsWith('per ')
        ? ' $unit'
        : ' / $unit';

    return Padding(
      padding: FarmerProductDetailsStyles.detailsPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: FarmerProductDetailsContentStyles.textStyle(nameColor),
          ),
          const SizedBox(height: 3),
          Text.rich(
            TextSpan(
              text: product.price,
              style: FarmerProductDetailsContentStyles.textSpanStyle(
                valueColor,
              ),
              children: [
                TextSpan(
                  text: unitLabel,
                  style: FarmerProductDetailsStyles.unitText,
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (product.isInActiveSale) ...[
            const SizedBox(height: 3),
            Container(
              padding: FarmerProductDetailsStyles.saleBadgePadding,
              decoration: FarmerProductDetailsStyles.saleBadgeDecoration,
              child: Text(
                'In Sale: ${product.activeSaleName ?? 'Admin Promotion'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FarmerProductDetailsStyles.saleBadgeText,
              ),
            ),
          ],
          const Spacer(),
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                color: product.isOutOfStock
                    ? AgrisellColors.statusRedText
                    : AgrisellColors.mutedText,
                size: FarmerProductDetailsStyles.iconSize,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  product.isOutOfStock
                      ? 'OUT OF STOCK'
                      : 'Stock: ${product.availableWeight}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FarmerProductDetailsContentStyles.textStyle2(product),
                ),
              ),
              _StockActionButton(
                isOutOfStock: product.isOutOfStock,
                isLoading: isRestocking,
                onPressed: onRestock,
              ),
            ],
          ),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: AgrisellColors.mutedText,
                size: FarmerProductDetailsStyles.iconSize,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  product.harvestDate,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FarmerProductDetailsStyles.dateText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
