part of 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart'; 
class _CheckoutContent extends StatelessWidget { const _CheckoutContent({
    required this.items, required this.deliveryAddress,
    required this.contactName, required this.phoneNumber,
    required this.onSelectLocation, required this.payment,
    required this.onSelectPayment, });
 final List<BasketCartItem> items;
  final String deliveryAddress; final String contactName;
  final String phoneNumber; final VoidCallback onSelectLocation;
  final OrderPayment payment;
  final ValueChanged<OrderPaymentMethod> onSelectPayment;
 @override
  Widget build(BuildContext context) { final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width < 380 ? 8.0 : 10.0; 
    return SingleChildScrollView( physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB( horizontalPadding,
        10, horizontalPadding,
        24, ),
      child: Column( children: [
          _DeliveryAddressPanel( address: deliveryAddress,
            contactName: contactName, phoneNumber: phoneNumber,
            onTap: onSelectLocation, ),
          const SizedBox(height: 7), if (items.isEmpty)
            const _EmptyCheckoutState() else
            _CheckoutItemsPanel(items: items), const SizedBox(height: 7),
          _PaymentMethodsPanel(
            payment: payment,
            onSelect: onSelectPayment,
          ), ],
      ), );
  } }
 class _DeliveryAddressPanel extends StatelessWidget {
  const _DeliveryAddressPanel({ required this.address,
    required this.contactName, required this.phoneNumber,
    required this.onTap, });
 final String address;
  final String contactName; final String phoneNumber;
  final VoidCallback onTap; 
  @override Widget build(BuildContext context) {
    return Semantics( button: true,
      label: 'Select exact delivery location', child: InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(8),
        child: DecoratedBox( decoration: BoxDecoration(
            color: AgrisellColors.surface, borderRadius: BorderRadius.circular(8),
            boxShadow: [ BoxShadow(
                color: AgrisellColors.brandBlack.withValues(alpha: 0.08), blurRadius: 12,
                offset: const Offset(0, 5), ),
            ], ),
          child: Padding( padding: const EdgeInsets.fromLTRB(12, 11, 9, 12),
            child: Row( crossAxisAlignment: CrossAxisAlignment.center,
              children: [ const Icon(
                  Icons.location_on_outlined, color: AgrisellColors.authGreen,
                  size: 19, ),
                const SizedBox(width: 7), Expanded(
                  child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                    children: [ _AddressContactLine(
                        contactName: contactName, phoneNumber: phoneNumber,
                      ), const SizedBox(height: 3),
                      Text( address,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle( color: AgrisellColors.brandBlack,
                          fontSize: 12, height: 1.2,
                          fontWeight: FontWeight.w500, ),
                      ), ],
                  ), ),
                const SizedBox(width: 6), const Icon(
                  Icons.chevron_right, color: AgrisellColors.dividerLine,
                  size: 27, ),
              ], ),
          ), ),
      ), );
  } }
 class _AddressContactLine extends StatelessWidget {
  const _AddressContactLine({ required this.contactName,
    required this.phoneNumber, });
 final String contactName;
  final String phoneNumber; 
  @override Widget build(BuildContext context) {
    return Text.rich( TextSpan(
        text: contactName, style: const TextStyle(
          color: AgrisellColors.brandBlack, fontSize: 12,
          height: 1.1, fontWeight: FontWeight.w800,
        ), children: [
          if (phoneNumber.isNotEmpty) TextSpan(
              text: '   $phoneNumber', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ), ],
      ), maxLines: 1,
      overflow: TextOverflow.ellipsis, );
  } }
 class _CheckoutItemsPanel extends StatelessWidget {
  const _CheckoutItemsPanel({required this.items}); 
  final List<BasketCartItem> items; 
  @override Widget build(BuildContext context) {
    return DecoratedBox( decoration: BoxDecoration(
        color: AgrisellColors.surface, borderRadius: BorderRadius.circular(8),
        boxShadow: [ BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.08), blurRadius: 12,
            offset: const Offset(0, 5), ),
        ], ),
      child: ClipRRect( borderRadius: BorderRadius.circular(8),
        child: Column( children: [
            for (var index = 0; index < items.length; index++) ...[ CheckoutItemTile(
                key: ValueKey(items[index].productId), item: items[index],
              ), if (index != items.length - 1)
                const Divider( height: 1,
                  thickness: 1, color: AgrisellColors.borderLine,
                ), ],
          ], ),
      ), );
  } }
