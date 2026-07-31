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
              style: FilledButton.styleFrom(
                minimumSize: const Size(190, 38),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                backgroundColor: AgrisellColors.authGreen,
                foregroundColor: AgrisellColors.surface,
                disabledBackgroundColor: AgrisellColors.brandBlack.withValues(
                  alpha: 0.16,
                ),
                disabledForegroundColor: AgrisellColors.brandBlack.withValues(
                  alpha: 0.56,
                ),
                elevation: 5,
                shadowColor: AgrisellColors.brandBlack.withValues(alpha: 0.25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: const Text(
                'Add new products',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  height: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (!isEnabled)
            const Padding(
              padding: EdgeInsets.only(top: 7),
              child: Text(
                'Product posting is available after verification.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }
}
