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
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final description = product.description.trim();
      final isCompact = constraints.maxHeight < 132;
      final valueColor = product.isSold
          ? AgrisellColors.mutedText
          : AgrisellColors.authGreen;
      final nameColor = product.isSold
          ? AgrisellColors.brandBlack.withValues(alpha: 0.72)
          : AgrisellColors.brandBlack;

      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: nameColor,
                fontSize: 13,
                height: 1.1,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text.rich(
              TextSpan(
                text: product.price,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 14,
                  height: 1,
                  fontWeight: FontWeight.w800,
                ),
                children: [
                  TextSpan(
                    text: ' / ${product.unit}',
                    style: const TextStyle(
                      color: AgrisellColors.mutedText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                description,
                maxLines: isCompact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AgrisellColors.mutedText,
                  fontSize: 12,
                  height: 1.25,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              product.harvestDate,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AgrisellColors.mutedText,
                fontSize: 10,
                height: 1,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Container(height: 1, color: AgrisellColors.borderLine),
            const SizedBox(height: 7),
            Row(
              children: [
                Icon(
                  product.isOutOfStock
                      ? Icons.inventory_2_outlined
                      : Icons.inventory_outlined,
                  color: valueColor,
                  size: 14,
                ),
                const SizedBox(width: 6),
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
                      fontSize: 11,
                      height: 1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  height: 28,
                  child: TextButton(
                    onPressed: isRestocking ? null : onRestock,
                    style: TextButton.styleFrom(
                      foregroundColor: AgrisellColors.authGreen,
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      minimumSize: const Size(0, 28),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: isRestocking
                        ? const SizedBox.square(
                            dimension: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            product.isOutOfStock ? 'Restock' : 'Add stock',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
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
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AgrisellColors.surface.withValues(alpha: 0.94),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AgrisellColors.brandBlack.withValues(alpha: 0.14),
                blurRadius: 7,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.edit_rounded,
            color: AgrisellColors.authGreen,
            size: 18,
          ),
        ),
      ),
    );
  }
}
