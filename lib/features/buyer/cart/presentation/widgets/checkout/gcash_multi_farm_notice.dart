part of 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';

Future<GcashPaymentSelection?> chooseGcashPayment(
  BuildContext context, {
  required List<BasketCartItem> items,
  required double total,
  required CheckoutPaymentRepository repository,
  GcashReceiptImagePicker? receiptImagePicker,
}) async {
  final sellerKeys = items
      .map(
        (item) => item.farmId == null
            ? 'seller:${item.sellerName}'
            : 'farm:${item.farmId}',
      )
      .toSet();
  if (sellerKeys.length != 1) {
    await showMultiFarmGcashNotice(context);
    return null;
  }
  if (!context.mounted) return null;
  return showGcashPaymentSheet(
    context,
    items: items,
    total: total,
    repository: repository,
    receiptImagePicker: receiptImagePicker,
  );
}

Future<void> showMultiFarmGcashNotice(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AgrisellColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.storefront_outlined,
              color: AgrisellColors.authGreen,
              size: 34,
            ),
            const SizedBox(height: 10),
            const Text(
              'Separate GCash payments needed',
              textAlign: TextAlign.center,
              style: SharedPresentationStyles.headingTitleBlack,
            ),
            const SizedBox(height: 7),
            const Text(
              'Your basket contains products from multiple farmers. One GCash reference cannot verify every seller, so use Cash on Delivery or check out one farmer at a time.',
              textAlign: TextAlign.center,
              style: SharedPresentationStyles.mutedCaptionLoose,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: GcashMultiFarmNoticeStyles.filledButtonStyle,
                child: const Text(
                  'Keep Cash on Delivery',
                  style: SharedPresentationStyles.captionExtraBold,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
