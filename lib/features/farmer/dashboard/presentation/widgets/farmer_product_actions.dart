part of 'package:agresell_app/features/farmer/dashboard/presentation/screens/farmer_dashboard_screen.dart';

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
      dimension: FarmerProductDetailsStyles.actionButtonDimension,
      child: IconButton(
        tooltip: label,
        onPressed: isLoading ? null : onPressed,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        color: AgrisellColors.authGreen,
        iconSize: FarmerProductDetailsStyles.actionIconSize,
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
          decoration: FarmerProductDetailsStyles.editButtonDecoration,
          child: const Icon(
            Icons.edit_outlined,
            color: AgrisellColors.authGreen,
            size: FarmerProductDetailsStyles.editIconSize,
          ),
        ),
      ),
    );
  }
}
