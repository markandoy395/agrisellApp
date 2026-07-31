part of 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';

class _CheckoutPriceLine extends StatelessWidget {
  const _CheckoutPriceLine({required this.item});

  final BasketCartItem item;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: item.priceLabel,
        style: const TextStyle(
          color: AgrisellColors.authGreen,
          fontSize: 13,
          height: 1,
          fontWeight: FontWeight.w800,
        ),
        children: [
          TextSpan(
            text: ' ${item.unit}',
            style: const TextStyle(
              color: AgrisellColors.brandBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
