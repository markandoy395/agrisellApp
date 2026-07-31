part of 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';

class GcashPaymentSelection {
  const GcashPaymentSelection({required this.farmId, required this.payment});

  final int farmId;
  final OrderPayment payment;
}

Future<GcashPaymentSelection?> showGcashPaymentSheet(
  BuildContext context, {
  required List<BasketCartItem> items,
  required double total,
  required CheckoutPaymentRepository repository,
}) {
  return showModalBottomSheet<GcashPaymentSelection>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AgrisellColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) =>
        _GcashPaymentSheet(items: items, total: total, repository: repository),
  );
}

class _GcashPaymentSheet extends StatefulWidget {
  const _GcashPaymentSheet({
    required this.items,
    required this.total,
    required this.repository,
  });

  final List<BasketCartItem> items;
  final double total;
  final CheckoutPaymentRepository repository;

  @override
  State<_GcashPaymentSheet> createState() => _GcashPaymentSheetState();
}

class _GcashPaymentSheetState extends State<_GcashPaymentSheet> {
  final _referenceController = TextEditingController();
  late Future<List<FarmerGcashDetails>> _detailsFuture;

  int? get _farmId => widget.items.firstOrNull?.farmId;
  bool get _referenceIsValid => RegExp(
    r'^[A-Za-z0-9 _-]{6,40}$',
  ).hasMatch(_referenceController.text.trim());

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
                maxLength: 40,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(fontSize: 13),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'GCash reference number',
                  hintText: 'Example: 1234 567 890123',
                  helperText:
                      'Use the reference on your receipt. The farmer still verifies it.',
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
              SizedBox(
                width: double.infinity,
                height: 38,
                child: FilledButton.icon(
                  key: const ValueKey('use-gcash-button'),
                  onPressed: _referenceIsValid
                      ? () => _confirm(details.farmId)
                      : null,
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

  void _confirm(int farmId) {
    Navigator.of(context).pop(
      GcashPaymentSelection(
        farmId: farmId,
        payment: OrderPayment.gcash(_referenceController.text),
      ),
    );
  }
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
