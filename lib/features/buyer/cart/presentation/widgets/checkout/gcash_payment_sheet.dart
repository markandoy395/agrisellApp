part of 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';

class GcashPaymentSelection {
  const GcashPaymentSelection({required this.farmId, required this.payment});

  final int? farmId;
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
    backgroundColor: GcashPaymentSheetStyles.sheetBackgroundColor,
    shape: GcashPaymentSheetStyles.sheetShape,
    builder: (context) => AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: FractionallySizedBox(
        heightFactor: .85,
        child: SafeArea(
          top: false,
          child: _GcashPaymentSheet(
            items: items,
            total: total,
            repository: repository,
            receiptImagePicker:
                receiptImagePicker ?? _pickDeviceGcashReceiptImage,
          ),
        ),
      ),
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
    // FutureBuilder attaches after the next rebuild when Retry is tapped.
    _detailsFuture.ignore();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: GcashPaymentSheetStyles.sheetBasePadding,
      child: FutureBuilder<List<FarmerGcashDetails>>(
        future: _detailsFuture,
        builder: (context, snapshot) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _GcashSheetHeader(),
            const SizedBox(height: GcashPaymentSheetStyles.headerGap),
            _GcashVerificationNotice(total: widget.total),
            const SizedBox(height: GcashPaymentSheetStyles.sectionGap),
            if (snapshot.connectionState != ConnectionState.done)
              const _GcashLoadingState()
            else if (snapshot.hasError)
              _GcashUnavailableState(onRetry: _retry, loadFailed: true)
            else if (snapshot.data?.firstOrNull case final details?) ...[
              _GcashAccountCard(details: details),
              const SizedBox(height: GcashPaymentSheetStyles.sectionGap),
              TextField(
                key: const ValueKey('gcash-reference-field'),
                controller: _referenceController,
                maxLength: 17,
                keyboardType: TextInputType.number,
                style: GcashPaymentSheetStyles.referenceInputTextStyle,
                onChanged: (_) => setState(() {}),
                decoration: GcashPaymentSheetStyles.referenceInputDecoration,
              ),
              const SizedBox(height: GcashPaymentSheetStyles.fieldGap),
              _GcashReceiptPicker(
                image: _receiptImage,
                error: _receiptError,
                picking: _pickingReceipt,
                onPick: _pickReceiptImage,
              ),
              const SizedBox(height: GcashPaymentSheetStyles.fieldGap),
              _GcashSubmitButton(
                onPressed: _canSubmit ? () => _confirm(details.farmId) : null,
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
