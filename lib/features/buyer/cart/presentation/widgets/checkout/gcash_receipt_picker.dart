part of 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';

class _GcashReceiptPicker extends StatelessWidget {
  const _GcashReceiptPicker({
    required this.image,
    required this.error,
    required this.picking,
    required this.onPick,
  });

  final GcashReceiptImage? image;
  final String? error;
  final bool picking;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final selected = image;
    return Container(
      width: double.infinity,
      padding: GcashPaymentSheetStyles.receiptPickerPadding,
      decoration: GcashPaymentSheetStyles.receiptPickerDecoration(
        hasSelected: selected != null,
        hasError: error != null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: GcashPaymentSheetStyles.previewBorderRadius,
                child: Container(
                  width: GcashPaymentSheetStyles.previewSize,
                  height: GcashPaymentSheetStyles.previewSize,
                  color: GcashPaymentSheetStyles.previewBackgroundColor,
                  child: selected == null
                      ? const Icon(
                          Icons.image_outlined,
                          color:
                              GcashPaymentSheetStyles.previewPlaceholderIconColor,
                          size:
                              GcashPaymentSheetStyles
                                  .previewPlaceholderIconSize,
                        )
                      : Image.memory(
                          selected.bytes,
                          fit: BoxFit.cover,
                          semanticLabel: 'Uploaded GCash receipt image',
                        ),
                ),
              ),
              const SizedBox(width: GcashPaymentSheetStyles.previewInfoGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selected == null
                          ? 'Upload receipt image'
                          : selected.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GcashPaymentSheetStyles.receiptTitleStyle,
                    ),
                    const SizedBox(
                      height: GcashPaymentSheetStyles.headerSubtitleGap,
                    ),
                    Text(
                      selected == null
                          ? 'Required before submitting the reference.'
                          : 'Receipt image ready for farmer review.',
                      style: GcashPaymentSheetStyles.receiptSubtitleStyle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: GcashPaymentSheetStyles.infoButtonGap),
              SizedBox(
                height: GcashPaymentSheetStyles.uploadButtonHeight,
                child: OutlinedButton.icon(
                  key: const ValueKey('gcash-receipt-upload-button'),
                  onPressed: picking ? null : onPick,
                  style: GcashPaymentSheetStyles.uploadButtonStyle,
                  icon: Icon(
                    picking
                        ? Icons.hourglass_empty_rounded
                        : Icons.upload_file_outlined,
                    size: GcashPaymentSheetStyles.uploadIconSize,
                  ),
                  label: Text(
                    picking ? 'Uploading' : 'Upload',
                    style: GcashPaymentSheetStyles.uploadButtonTextStyle,
                  ),
                ),
              ),
            ],
          ),
          if (error case final message?) ...[
            const SizedBox(height: GcashPaymentSheetStyles.errorGap),
            Text(
              message,
              style: GcashPaymentSheetStyles.receiptErrorTextStyle,
            ),
          ],
        ],
      ),
    );
  }
}
