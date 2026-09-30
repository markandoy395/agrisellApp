part of 'checkout_screen.dart';

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _controller = BasketController.instance;
  final _orderController = OrderController.instance;
  final _profile = currentAuthenticatedUserProfile();
  final _voucherController = TextEditingController();
  late final ConfirmedLocationRepository _locationRepository;
  ConfirmedLocation? _deliveryLocation;
  OrderPayment _payment = const OrderPayment.cashOnDelivery();
  int? _gcashFarmId;
  var _isPlacingOrder = false;
  AppliedVoucher? _appliedVoucher;
  var _isValidatingVoucher = false;
  String? _voucherError;

  @override
  void initState() {
    super.initState();
    _locationRepository =
        widget.locationRepository ?? ConfirmedLocationRepository();
    unawaited(_restoreDeliveryLocation());
  }

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  Future<void> _restoreDeliveryLocation() async {
    final saved = await _locationRepository.load(LocationOwnerRole.buyer);
    final location = saved ?? _profileDeliveryLocation();
    if (location == null || !mounted) return;
    setState(() => _deliveryLocation = location);
    if (saved == null) {
      unawaited(_locationRepository.confirm(LocationOwnerRole.buyer, location));
    }
  }

  ConfirmedLocation? _profileDeliveryLocation() {
    if (!MapCoordinates.isValid(
      latitude: _profile.shippingLatitude,
      longitude: _profile.shippingLongitude,
    )) {
      return null;
    }
    return ConfirmedLocation(
      latitude: _profile.shippingLatitude!,
      longitude: _profile.shippingLongitude!,
      accuracyMeters: 0,
      capturedAt: DateTime.now(),
      address: WrittenAddress.valueOrNull(_profile.address),
    );
  }

  String get _defaultDeliveryAddress {
    final initial = widget.initialDeliveryAddress?.trim() ?? '';
    return WrittenAddress.valueOrNull(initial) ??
        WrittenAddress.valueOrNull(_profile.address) ??
        '';
  }

  String get _deliveryAddress =>
      WrittenAddress.valueOrNull(_deliveryLocation?.address) ??
      (_defaultDeliveryAddress.isEmpty
          ? 'Select a delivery location'
          : _defaultDeliveryAddress);

  Future<void> _openMessages() async {
    final items = _controller.selectedItems;
    if (items.isEmpty) {
      _showConversationMessage('Select an item before messaging its farmer.');
      return;
    }

    final item = items.first;
    if (!items.every((candidate) => _hasSameSeller(item, candidate))) {
      _showConversationMessage(
        'This checkout contains multiple farmers. Select items from one farmer to open the correct conversation.',
      );
      return;
    }

    final parsedCommodityId = int.tryParse(item.productId.trim());
    final commodityId = parsedCommodityId != null && parsedCommodityId > 0
        ? item.productId.trim()
        : null;
    final farmId = item.farmId != null && item.farmId! > 0 ? item.farmId : null;
    if (commodityId == null && farmId == null) {
      _showConversationMessage(
        'This farmer conversation is unavailable because its reference is invalid.',
      );
      return;
    }

    await BuyerConversationLauncher.open(
      context,
      sellerName: item.sellerName,
      commodityId: commodityId,
      farmId: farmId,
      productName: item.productName,
      repository: widget.messagingRepository,
    );
  }

  bool _hasSameSeller(BasketCartItem first, BasketCartItem candidate) {
    final firstFarmId = first.farmId;
    final candidateFarmId = candidate.farmId;
    if (firstFarmId != null &&
        firstFarmId > 0 &&
        candidateFarmId != null &&
        candidateFarmId > 0) {
      return firstFarmId == candidateFarmId;
    }
    return first.sellerName.trim() == candidate.sellerName.trim() &&
        first.sellerLocation.trim() == candidate.sellerLocation.trim();
  }

  void _showConversationMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showAppSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _selectDeliveryLocation() async {
    final location = await showLocationSelector(
      context,
      role: LocationOwnerRole.buyer,
      initialAddress: _deliveryLocation?.address ?? _defaultDeliveryAddress,
      repository: _locationRepository,
    );
    if (location == null || !mounted) return;
    setState(() => _deliveryLocation = location);
    ScaffoldMessenger.of(context).showAppSnackBar(
      const SnackBar(
        content: Text('Delivery location successfully confirmed.'),
      ),
    );
  }

  double get _itemsSubtotal {
    var subtotal = 0.0;
    for (final item in _controller.selectedItems) {
      if (item.hasSale && item.originalPriceLabel != null) {
        subtotal += item.quantity * _parsePrice(item.originalPriceLabel!);
      } else {
        subtotal += item.quantity * item.pricePerKg;
      }
    }
    return double.parse(subtotal.toStringAsFixed(2));
  }

  double get _productSaleDiscount {
    var discount = 0.0;
    for (final item in _controller.selectedItems) {
      if (item.hasSale && item.originalPriceLabel != null) {
        final original = _parsePrice(item.originalPriceLabel!);
        if (original > item.pricePerKg) {
          discount += item.quantity * (original - item.pricePerKg);
        }
      }
    }
    return double.parse(discount.toStringAsFixed(2));
  }

  double get _voucherDiscount => _appliedVoucher?.discountAmount ?? 0.0;

  double get _finalCheckoutTotal {
    final total = _controller.selectedTotal - _voucherDiscount;
    return total < 0 ? 0.0 : double.parse(total.toStringAsFixed(2));
  }

  static double _parsePrice(String price) {
    final normalized = price.replaceAll(',', '');
    final match = RegExp(r'\d+(?:\.\d+)?').firstMatch(normalized);
    if (match == null) return 0.0;
    return double.tryParse(match.group(0) ?? '') ?? 0.0;
  }

  Future<void> _applyVoucher() async {
    final code = _voucherController.text.trim();
    if (code.isEmpty) {
      setState(() => _voucherError = 'Please enter a voucher code.');
      return;
    }
    setState(() {
      _isValidatingVoucher = true;
      _voucherError = null;
    });
    try {
      final voucher = await widget.voucherService.validateVoucher(
        code: code,
        items: _controller.selectedItems,
      );
      if (!mounted) return;
      setState(() {
        _appliedVoucher = voucher;
        _voucherError = null;
      });
      ScaffoldMessenger.of(context).showAppSnackBar(
        SnackBar(
          content: Text(
            'Voucher "${voucher.code}" applied: ${voucher.discountLabel}',
          ),
        ),
      );
    } on VoucherValidationException catch (error) {
      if (!mounted) return;
      setState(() => _voucherError = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _voucherError = 'Unable to validate voucher. Please try again.',
      );
    } finally {
      if (mounted) setState(() => _isValidatingVoucher = false);
    }
  }

  void _removeVoucher() {
    setState(() {
      _appliedVoucher = null;
      _voucherError = null;
      _voucherController.clear();
    });
  }

  Future<void> _browseVouchers() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CheckoutVoucherPickerSheet(
        cartItems: _controller.selectedItems,
        onSelectVoucher: (voucher) {
          _voucherController.text = voucher.code ?? '';
          unawaited(_applyVoucher());
        },
      ),
    );
  }

  Future<void> _selectPaymentMethod(OrderPaymentMethod method) async {
    if (method == OrderPaymentMethod.cashOnDelivery) {
      setState(() {
        _payment = const OrderPayment.cashOnDelivery();
        _gcashFarmId = null;
      });
      return;
    }
    final selection = await chooseGcashPayment(
      context,
      items: _controller.selectedItems,
      total: _finalCheckoutTotal,
      repository: widget.paymentRepository,
      receiptImagePicker: widget.gcashReceiptImagePicker,
    );
    if (selection == null || !mounted) return;
    setState(() {
      _payment = selection.payment;
      _gcashFarmId = selection.farmId;
    });
  }

  Future<void> _placeOrder() async {
    if (_isPlacingOrder) return;
    final selectedItems = _controller.selectedItems;
    if (selectedItems.isEmpty) return;
    if (!_gcashMatches(selectedItems)) {
      ScaffoldMessenger.of(context).showAppSnackBar(
        const SnackBar(
          content: Text('Review the GCash details for the selected farmer.'),
        ),
      );
      return;
    }

    final location = _deliveryLocation;
    final deliveryAddress = WrittenAddress.valueOrNull(location?.address);
    if (location == null || deliveryAddress == null) {
      ScaffoldMessenger.of(context).showAppSnackBar(
        const SnackBar(
          content: Text('Confirm your exact delivery map location first.'),
        ),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);
    final List<PlacedOrder> orders;
    try {
      var itemsToSubmit = selectedItems;
      if (_appliedVoucher != null) {
        itemsToSubmit = selectedItems.map((item) {
          final parsedId = int.tryParse(item.productId.trim());
          final isEligible =
              _appliedVoucher!.applicableCommodityIds.isEmpty ||
              (parsedId != null &&
                  _appliedVoucher!.applicableCommodityIds.contains(parsedId));
          if (!isEligible) return item;

          var discountedPrice = item.pricePerKg;
          if (_appliedVoucher!.discountType == 'percentage') {
            discountedPrice =
                item.pricePerKg * (1 - _appliedVoucher!.discountValue / 100);
          } else if (_appliedVoucher!.discountType == 'sale_price') {
            discountedPrice = _appliedVoucher!.discountValue;
          } else if (_appliedVoucher!.discountType == 'amount') {
            final itemTotal = item.pricePerKg * item.quantity;
            final portion =
                itemTotal > 0 && _controller.selectedTotal > 0
                    ? (_appliedVoucher!.discountAmount /
                        _controller.selectedTotal)
                    : 0;
            discountedPrice = (item.pricePerKg * (1 - portion)).clamp(0, double.infinity);
          }
          discountedPrice = double.parse(discountedPrice.toStringAsFixed(2));
          return item.copyWith(pricePerKg: discountedPrice);
        }).toList();
      }

      orders = await _orderController.placeToShipOrders(
        items: itemsToSubmit,
        deliveryAddress: deliveryAddress,
        phoneNumber: _profile.phoneNumber,
        deliveryLatitude: location.latitude,
        deliveryLongitude: location.longitude,
        payment: _payment,
      );
    } on OrderPlacementException catch (error) {
      if (!mounted) return;
      await _refreshInventoryAfterFailure(error.message, selectedItems);
      if (!mounted) return;
      setState(() => _isPlacingOrder = false);
      ScaffoldMessenger.of(
        context,
      ).showAppSnackBar(SnackBar(content: Text(error.message)));
      return;
    } on Object {
      if (!mounted) return;
      setState(() => _isPlacingOrder = false);
      ScaffoldMessenger.of(context).showAppSnackBar(
        const SnackBar(
          content: Text('The order could not be saved. Please try again.'),
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isPlacingOrder = false);
    if (orders.isEmpty) return;
    _controller.removeSelected();
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showAppSnackBar(
      const SnackBar(content: Text('Order placed successfully.')),
    );
    Navigator.of(context).pushReplacement(
      agrisellPageRoute<void>(builder: (_) => const OrderTrackingScreen()),
    );
  }

  Future<void> _refreshInventoryAfterFailure(
    String message,
    Iterable<BasketCartItem> submittedItems,
  ) async {
    final normalized = message.toLowerCase();
    final isInventoryFailure =
        normalized.contains('stock') ||
        normalized.contains('remains') ||
        normalized.contains('no longer available') ||
        normalized.contains('not accepting orders');
    if (!isInventoryFailure) return;
    final quantities = await widget.inventoryRepository.loadOrderableQuantities(
      submittedItems.map((item) => item.productId),
    );
    _controller.reconcileAvailableQuantities(quantities);
  }

  bool _gcashMatches(List<BasketCartItem> items) {
    if (_payment.method != OrderPaymentMethod.gcash) return true;
    final farmIds = items.map((item) => item.farmId).toSet();
    return farmIds.length == 1 && farmIds.single == _gcashFarmId;
  }

  @override
  Widget build(BuildContext context) => BuyerResponsiveText(
    child: Scaffold(
      backgroundColor: AgrisellColors.homeBackground,
      bottomNavigationBar: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => _CheckoutBottomBar(
          selectedQuantity: _controller.selectedQuantity,
          total: _finalCheckoutTotal,
          isPlacingOrder: _isPlacingOrder,
          onPlaceOrder: _placeOrder,
        ),
      ),
      body: Column(
        children: [
          _CheckoutHeader(onMessagesTap: _openMessages),
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => _CheckoutContent(
                items: _controller.selectedItems,
                deliveryAddress: _deliveryAddress,
                contactName: _profile.name,
                phoneNumber: _profile.phoneNumber,
                onSelectLocation: _selectDeliveryLocation,
                payment: _payment,
                onSelectPayment: _selectPaymentMethod,
                subtotal: _itemsSubtotal,
                productSaleDiscount: _productSaleDiscount,
                voucherDiscount: _voucherDiscount,
                finalTotal: _finalCheckoutTotal,
                voucherController: _voucherController,
                appliedVoucher: _appliedVoucher,
                isValidatingVoucher: _isValidatingVoucher,
                voucherError: _voucherError,
                onApplyVoucher: _applyVoucher,
                onRemoveVoucher: _removeVoucher,
                onBrowseVouchers: _browseVouchers,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
