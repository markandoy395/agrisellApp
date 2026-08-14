part of 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';

class _CheckoutBottomBar extends StatelessWidget {
  const _CheckoutBottomBar({
    required this.selectedQuantity,
    required this.total,
    required this.isPlacingOrder,
    required this.onPlaceOrder,
  });

  final int selectedQuantity;
  final double total;
  final bool isPlacingOrder;
  final VoidCallback onPlaceOrder;

  @override
  Widget build(BuildContext context) {
    final enabled = selectedQuantity > 0 && !isPlacingOrder;
    return NotchedCheckoutFooter(
      actionLabel: isPlacingOrder ? 'Placing...' : 'Place Order',
      enabled: enabled,
      onActionTap: onPlaceOrder,
      leading: Align(
        alignment: Alignment.centerRight,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Text.rich(
            TextSpan(
              text: 'Total ',
              style: const TextStyle(
                color: AgrisellColors.brandBlack,
                fontSize: 13,
                height: 1,
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(
                  text: formatBasketPeso(total),
                  style: const TextStyle(
                    color: AgrisellColors.authGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            textAlign: TextAlign.right,
          ),
        ),
      ),
    );
  }
}
