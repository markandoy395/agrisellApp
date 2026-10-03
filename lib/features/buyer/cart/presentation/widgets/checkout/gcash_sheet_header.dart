part of 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';

class _GcashSheetHeader extends StatelessWidget {
  const _GcashSheetHeader();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pay with GCash',
              style: GcashPaymentSheetStyles.headerTitleStyle,
            ),
            SizedBox(height: GcashPaymentSheetStyles.headerSubtitleGap),
            Text(
              'Manual transfer to the farmer',
              style: GcashPaymentSheetStyles.headerSubtitleStyle,
            ),
          ],
        ),
      ),
      IconButton(
        tooltip: 'Close GCash details',
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(
          Icons.close_rounded,
          size: GcashPaymentSheetStyles.closeIconSize,
        ),
      ),
    ],
  );
}
