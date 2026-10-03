part of 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';

class _DeliveryAddressPanel extends StatelessWidget {
  const _DeliveryAddressPanel({
    required this.address,
    required this.contactName,
    required this.phoneNumber,
    required this.onTap,
  });

  final String address;
  final String contactName;
  final String phoneNumber;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Select exact delivery location',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: DecoratedBox(
          decoration: CheckoutContentStyles.cardDecoration,
          child: Padding(
            padding: CheckoutContentStyles.addressPadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: AgrisellColors.authGreen,
                  size: 19,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AddressContactLine(
                        contactName: contactName,
                        phoneNumber: phoneNumber,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: CheckoutContentStyles.addressTextStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right,
                  color: AgrisellColors.dividerLine,
                  size: 27,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddressContactLine extends StatelessWidget {
  const _AddressContactLine({
    required this.contactName,
    required this.phoneNumber,
  });

  final String contactName;
  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: contactName,
        style: CheckoutContentStyles.contactNameTextStyle,
        children: [
          if (phoneNumber.isNotEmpty)
            TextSpan(
              text: '   $phoneNumber',
              style: CheckoutContentStyles.contactPhoneTextStyle,
            ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
