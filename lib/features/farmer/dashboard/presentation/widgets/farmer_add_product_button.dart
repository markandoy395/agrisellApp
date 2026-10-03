part of 'package:agresell_app/features/farmer/dashboard/presentation/screens/farmer_dashboard_screen.dart';

class _FarmerAddProductButton extends StatelessWidget {
  const _FarmerAddProductButton({
    required this.horizontalPadding,
    required this.isEnabled,
    required this.onPressed,
  });

  final double horizontalPadding;
  final bool isEnabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 14, horizontalPadding, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 38,
            child: FilledButton(
              onPressed: isEnabled ? onPressed : null,
              style: FarmerAddProductButtonStyles.filledButtonStyle,
              child: const Text(
                'Add new products',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FarmerAddProductButtonStyles.addNewProductsText,
              ),
            ),
          ),
          if (!isEnabled)
            const Padding(
              padding: EdgeInsets.only(top: 7),
              child: Text(
                'Product posting is available after verification.',
                textAlign: TextAlign.center,
                style: SharedPresentationStyles.captionMedium,
              ),
            ),
        ],
      ),
    );
  }
}
