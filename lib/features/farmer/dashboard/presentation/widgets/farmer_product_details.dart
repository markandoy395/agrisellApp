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
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: nameColor,
              fontSize: 15,
              height: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text.rich(
            TextSpan(
              text: product.price,
              style: TextStyle(
                color: valueColor,
                fontSize: 15,
                height: 1,
                fontWeight: FontWeight.w800,
              ),
              children: [
                TextSpan(
                  text: unitLabel,
                  style: const TextStyle(
                    color: AgrisellColors.mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (product.isInActiveSale) ...[
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: AgrisellColors.forestSoft,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: AgrisellColors.authGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'In Sale: ${product.activeSaleName ?? 'Admin Promotion'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AgrisellColors.authGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
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
                size: 14,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  product.isOutOfStock
                      ? 'OUT OF STOCK'
                      : 'Stock: ${product.availableWeight}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: product.isOutOfStock
                        ? AgrisellColors.statusRedText
                        : AgrisellColors.mutedText,
                    fontSize: 12,
                    height: 1,
                    fontWeight: FontWeight.w600,
                  ),
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
                size: 14,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  product.harvestDate,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AgrisellColors.mutedText,
                    fontSize: 12,
                    height: 1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StockActionButton extends StatelessWidget {
  const _StockActionButton({
    required this.isOutOfStock,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isOutOfStock;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label = isOutOfStock ? 'Restock product' : 'Add product stock';
    return SizedBox.square(
      dimension: 30,
      child: IconButton(
        tooltip: label,
        onPressed: isLoading ? null : onPressed,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        color: AgrisellColors.authGreen,
        iconSize: 18,
        icon: isLoading
            ? const SizedBox.square(
                dimension: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add_circle_outline_rounded),
      ),
    );
  }
}

class _EditProductButton extends StatelessWidget {
  const _EditProductButton({required this.productName, required this.onTap});

  final String productName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Edit $productName',
      child: InkResponse(
        onTap: onTap,
        radius: 19,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AgrisellColors.surface.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: AgrisellColors.borderLine),
          ),
          child: const Icon(
            Icons.edit_outlined,
            color: AgrisellColors.authGreen,
            size: 16,
          ),
        ),
      ),
    );
  }
}
