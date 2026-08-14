part of 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';

class GcashPaymentSelection {
  const GcashPaymentSelection({required this.farmId, required this.payment});

  final int farmId;
  final OrderPayment payment;
}

typedef GcashReceiptImagePicker = Future<GcashReceiptImage?> Function();

class GcashReceiptImage {
  const GcashReceiptImage({
    required this.fileName,
    required this.bytes,
    required this.proofReference,
  });

  final String fileName;
  final Uint8List bytes;
  final String proofReference;
}

Future<GcashPaymentSelection?> showGcashPaymentSheet(
  BuildContext context, {
  required List<BasketCartItem> items,
  required double total,
  required CheckoutPaymentRepository repository,
  GcashReceiptImagePicker? receiptImagePicker,
}) {
  return showModalBottomSheet<GcashPaymentSelection>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AgrisellColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _GcashPaymentSheet(
      items: items,
      total: total,
      repository: repository,
      receiptImagePicker: receiptImagePicker ?? _pickDeviceGcashReceiptImage,
    ),
  );
}

class _GcashPaymentSheet extends StatefulWidget {
  const _GcashPaymentSheet({
    required this.items,
    required this.total,
    required this.repository,
    required this.receiptImagePicker,
  });

  final List<BasketCartItem> items;
  final double total;
  final CheckoutPaymentRepository repository;
  final GcashReceiptImagePicker receiptImagePicker;

  @override
  State<_GcashPaymentSheet> createState() => _GcashPaymentSheetState();
}

class _GcashPaymentSheetState extends State<_GcashPaymentSheet> {
  final _referenceController = TextEditingController();
  late Future<List<FarmerGcashDetails>> _detailsFuture;
  GcashReceiptImage? _receiptImage;
  String? _receiptError;
  var _pickingReceipt = false;

  int? get _farmId => widget.items.firstOrNull?.farmId;
  bool get _referenceIsValid =>
      OrderPayment.isValidGcashReference(_referenceController.text);
  bool get _canSubmit => _referenceIsValid && _receiptImage != null;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  void _loadDetails() {
    final farmId = _farmId;
    _detailsFuture = farmId == null
        ? Future.value(const [])
        : widget.repository.loadGcashDetails([farmId]);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + bottomInset),
      child: FutureBuilder<List<FarmerGcashDetails>>(
        future: _detailsFuture,
        builder: (context, snapshot) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _GcashSheetHeader(),
            const SizedBox(height: 14),
            _GcashVerificationNotice(total: widget.total),
            const SizedBox(height: 12),
            if (snapshot.connectionState != ConnectionState.done)
              const _GcashLoadingState()
            else if (snapshot.hasError)
              _GcashUnavailableState(onRetry: _retry)
            else if (snapshot.data?.firstOrNull case final details?) ...[
              _GcashAccountCard(details: details),
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('gcash-reference-field'),
                controller: _referenceController,
                maxLength: 17,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 13),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'GCash reference number',
                  hintText: 'Example: 1234 567 890123',
                  helperText:
                      'Enter the 13-digit number printed on your receipt.',
                  helperMaxLines: 2,
                  prefixIcon: const Icon(Icons.receipt_long_outlined, size: 19),
                  filled: true,
                  fillColor: AgrisellColors.searchBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _GcashReceiptPicker(
                image: _receiptImage,
                error: _receiptError,
                picking: _pickingReceipt,
                onPick: _pickReceiptImage,
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 38,
                child: FilledButton.icon(
                  key: const ValueKey('use-gcash-button'),
                  onPressed: _canSubmit ? () => _confirm(details.farmId) : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AgrisellColors.authGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.verified_user_outlined, size: 17),
                  label: const Text(
                    'Submit reference for verification',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ] else
              _GcashUnavailableState(onRetry: _retry),
          ],
        ),
      ),
    );
  }

  void _retry() => setState(_loadDetails);

  Future<void> _pickReceiptImage() async {
    setState(() {
      _pickingReceipt = true;
      _receiptError = null;
    });
    try {
      final image = await widget.receiptImagePicker();
      if (!mounted) return;
      setState(() => _receiptImage = image ?? _receiptImage);
    } on GcashReceiptImageException catch (error) {
      if (!mounted) return;
      setState(() => _receiptError = error.message);
    } on Exception {
      if (!mounted) return;
      setState(() => _receiptError = 'Unable to upload receipt image.');
    } finally {
      if (mounted) setState(() => _pickingReceipt = false);
    }
  }

  void _confirm(int farmId) {
    final receipt = _receiptImage;
    if (!_referenceIsValid || receipt == null) {
      setState(() {
        _receiptError ??= 'Upload a GCash receipt image first.';
      });
      return;
    }
    Navigator.of(context).pop(
      GcashPaymentSelection(
        farmId: farmId,
        payment: OrderPayment.gcash(
          _referenceController.text,
          receiptImageReference: receipt.proofReference,
          receiptImageName: receipt.fileName,
        ),
      ),
    );
  }
}

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
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: selected == null
            ? AgrisellColors.searchBackground
            : AgrisellColors.forestSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: error == null
              ? AgrisellColors.borderLine
              : AgrisellColors.statusRedText,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 46,
                  height: 46,
                  color: AgrisellColors.surface,
                  child: selected == null
                      ? const Icon(
                          Icons.image_outlined,
                          color: AgrisellColors.mutedText,
                          size: 20,
                        )
                      : Image.memory(
                          selected.bytes,
                          fit: BoxFit.cover,
                          semanticLabel: 'Uploaded GCash receipt image',
                        ),
                ),
              ),
              const SizedBox(width: 10),
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
                      style: const TextStyle(
                        color: AgrisellColors.brandBlack,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selected == null
                          ? 'Required before submitting the reference.'
                          : 'Receipt image ready for farmer review.',
                      style: const TextStyle(
                        color: AgrisellColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 36,
                child: OutlinedButton.icon(
                  key: const ValueKey('gcash-receipt-upload-button'),
                  onPressed: picking ? null : onPick,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    foregroundColor: AgrisellColors.authGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(
                    picking
                        ? Icons.hourglass_empty_rounded
                        : Icons.upload_file_outlined,
                    size: 16,
                  ),
                  label: Text(
                    picking ? 'Uploading' : 'Upload',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (error case final message?) ...[
            const SizedBox(height: 7),
            Text(
              message,
              style: const TextStyle(
                color: AgrisellColors.statusRedText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class GcashReceiptImageException implements Exception {
  const GcashReceiptImageException(this.message);
  final String message;
}

Future<GcashReceiptImage?> _pickDeviceGcashReceiptImage() async {
  final image = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: 1280,
    maxHeight: 1280,
    imageQuality: 84,
  );
  if (image == null) return null;
  final bytes = await image.readAsBytes();
  final fileName = _imageFileName(image);
  final error = _validateReceiptImage(fileName: fileName, bytes: bytes);
  if (error != null) throw GcashReceiptImageException(error);
  return GcashReceiptImage(
    fileName: fileName,
    bytes: bytes,
    proofReference:
        'local-secure://gcash-receipts/${DateTime.now().microsecondsSinceEpoch}',
  );
}

String _imageFileName(XFile image) {
  if (image.name.trim().isNotEmpty) return image.name.trim();
  return image.path.split(RegExp(r'[\\/]')).last;
}

String? _validateReceiptImage({
  required String fileName,
  required Uint8List bytes,
}) {
  final cleanFileName = fileName.trim();
  if (cleanFileName.isEmpty) return 'Upload a GCash receipt image.';
  if (RegExp(r'[\\/:*?"<>|]').hasMatch(cleanFileName) ||
      RegExp(
        r'\.(apk|bat|cmd|dll|exe|html?|jar|js|msi|php|sh|svg)(\.|$)',
        caseSensitive: false,
      ).hasMatch(cleanFileName)) {
    return 'Choose a safe JPG, PNG, or WEBP image.';
  }
  final extension = cleanFileName.split('.').last.toLowerCase();
  if (!{'jpg', 'jpeg', 'png', 'webp'}.contains(extension)) {
    return 'Only JPG, PNG, or WEBP receipt images are allowed.';
  }
  if (bytes.isEmpty) return 'Receipt image file is empty.';
  if (bytes.length > 5 * 1024 * 1024) {
    return 'Receipt image must be 5 MB or smaller.';
  }
  return null;
}

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
              style: TextStyle(
                color: AgrisellColors.headingGreen,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Manual transfer to the farmer',
              style: TextStyle(color: AgrisellColors.mutedText, fontSize: 12),
            ),
          ],
        ),
      ),
      IconButton(
        tooltip: 'Close GCash details',
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.close_rounded, size: 20),
      ),
    ],
  );
}
