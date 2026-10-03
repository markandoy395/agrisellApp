part of 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';

class _EmptyCheckoutState extends StatelessWidget {
  const _EmptyCheckoutState();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: EmptyCheckoutStateStyles.decoratedBoxDecoration,
      child: const SizedBox(
        width: double.infinity,
        height: 130,
        child: Center(
          child: Text(
            'No selected items for checkout.',
            textAlign: TextAlign.center,
            style: EmptyCheckoutStateStyles.noSelectedItemsForCheckoutText,
          ),
        ),
      ),
    );
  }
}
