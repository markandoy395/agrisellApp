part of 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';

class _CheckoutContent extends StatelessWidget {
  const _CheckoutContent({
    required this.items,
    required this.deliveryAddress,
    required this.contactName,
    required this.phoneNumber,
    required this.onSelectLocation,
    required this.payment,
    required this.onSelectPayment,
    required this.subtotal,
    required this.productSaleDiscount,
    required this.voucherDiscount,
    required this.finalTotal,
    required this.voucherController,
    required this.appliedVoucher,
    required this.isValidatingVoucher,
    required this.voucherError,
    required this.onApplyVoucher,
    required this.onRemoveVoucher,
    this.onBrowseVouchers,
  });

  final List<BasketCartItem> items;
  final String deliveryAddress;
  final String contactName;
  final String phoneNumber;
  final VoidCallback onSelectLocation;
  final OrderPayment payment;
  final ValueChanged<OrderPaymentMethod> onSelectPayment;
  final double subtotal;
  final double productSaleDiscount;
  final double voucherDiscount;
  final double finalTotal;
  final TextEditingController voucherController;
  final AppliedVoucher? appliedVoucher;
  final bool isValidatingVoucher;
  final String? voucherError;
  final VoidCallback onApplyVoucher;
  final VoidCallback onRemoveVoucher;
  final VoidCallback? onBrowseVouchers;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = CheckoutContentStyles.horizontalPadding(width);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: CheckoutContentStyles.scrollPadding(horizontalPadding),
      child: Column(
        children: [
          _DeliveryAddressPanel(
            address: deliveryAddress,
            contactName: contactName,
            phoneNumber: phoneNumber,
            onTap: onSelectLocation,
          ),
          const SizedBox(height: 7),
          if (items.isEmpty)
            const _EmptyCheckoutState()
          else ...[
            _CheckoutItemsPanel(items: items),
            const SizedBox(height: 7),
            _CheckoutVoucherPanel(
              controller: voucherController,
              appliedVoucher: appliedVoucher,
              isValidating: isValidatingVoucher,
              errorMessage: voucherError,
              onApply: onApplyVoucher,
              onRemove: onRemoveVoucher,
              onBrowseVouchers: onBrowseVouchers,
            ),
            const SizedBox(height: 7),
            _CheckoutOrderSummaryPanel(
              subtotal: subtotal,
              productSaleDiscount: productSaleDiscount,
              voucherDiscount: voucherDiscount,
              finalTotal: finalTotal,
              appliedVoucherCode: appliedVoucher?.code,
            ),
          ],
          const SizedBox(height: 7),
          _PaymentMethodsPanel(payment: payment, onSelect: onSelectPayment),
        ],
      ),
    );
  }
}

class _CheckoutItemsPanel extends StatelessWidget {
  const _CheckoutItemsPanel({required this.items});

  final List<BasketCartItem> items;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: CheckoutContentStyles.cardDecoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            for (var index = 0; index < items.length; index++) ...[
              CheckoutItemTile(
                key: ValueKey(items[index].productId),
                item: items[index],
              ),
              if (index != items.length - 1)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AgrisellColors.borderLine,
                ),
            ],
          ],
        ),
      ),
    );
  }
}
