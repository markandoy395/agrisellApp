part of 'checkout_screen.dart';

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _controller = BasketController.instance;
  final _orderController = OrderController.instance;
  final _profile = currentAuthenticatedUserProfile();
  late final CheckoutDeliveryLocationCoordinator _locationCoordinator;
  late final CheckoutVoucherCoordinator _voucherCoordinator;
  ConfirmedLocation? _deliveryLocation;
  OrderPayment _payment = const OrderPayment.cashOnDelivery();
  int? _gcashFarmId;
  var _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    _locationCoordinator = CheckoutDeliveryLocationCoordinator(
      repository: widget.locationRepository ?? ConfirmedLocationRepository(),
      profile: _profile,
      initialDeliveryAddress: widget.initialDeliveryAddress,
    );
    _voucherCoordinator = CheckoutVoucherCoordinator(
      voucherService: widget.voucherService,
    );
    unawaited(_restoreDeliveryLocation());
  }

  @override
  void dispose() {
    _voucherCoordinator.dispose();
    super.dispose();
  }

  Future<void> _restoreDeliveryLocation() async {
    final location = await _locationCoordinator.restoreLocation();
    if (location == null || !mounted) return;
    setState(() => _deliveryLocation = location);
  }

  String get _deliveryAddress =>
      _locationCoordinator.resolveDisplayAddress(_deliveryLocation);

  Future<void> _selectDeliveryLocation() async {
    final location = await _locationCoordinator.selectLocation(
      context,
      currentLocation: _deliveryLocation,
    );
    if (location == null || !mounted) return;
    setState(() => _deliveryLocation = location);
  }

  Future<void> _openMessages() => CheckoutFarmerMessenger.openFarmerConversation(
        context,
        items: _controller.selectedItems,
        messagingRepository: widget.messagingRepository,
      );

  double get _itemsSubtotal =>
      CheckoutPriceCalculator.calculateItemsSubtotal(_controller.selectedItems);

  double get _productSaleDiscount =>
      CheckoutPriceCalculator.calculateProductSaleDiscount(
        _controller.selectedItems,
      );

  double get _voucherDiscount =>
      _voucherCoordinator.appliedVoucher?.discountAmount ?? 0.0;

  double get _finalCheckoutTotal =>
      CheckoutPriceCalculator.calculateFinalTotal(
        selectedTotal: _controller.selectedTotal,
        voucherDiscount: _voucherDiscount,
      );

  Future<void> _applyVoucher() async {
    setState(() {});
    await _voucherCoordinator.applyVoucher(context, _controller.selectedItems);
    if (mounted) setState(() {});
  }

  void _removeVoucher() => setState(() => _voucherCoordinator.removeVoucher());

  Future<void> _browseVouchers() => _voucherCoordinator.browseVouchers(
        context,
        _controller.selectedItems,
        _applyVoucher,
      );

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
    setState(() => _isPlacingOrder = true);
    try {
      await CheckoutOrderSubmission.placeOrder(
        context: context,
        orderController: _orderController,
        inventoryRepository: widget.inventoryRepository,
        basketController: _controller,
        items: _controller.selectedItems,
        location: _deliveryLocation,
        phoneNumber: _profile.phoneNumber,
        payment: _payment,
        gcashFarmId: _gcashFarmId,
        appliedVoucher: _voucherCoordinator.appliedVoucher,
      );
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) => BuyerResponsiveText(
    child: Scaffold(
      backgroundColor: CheckoutScreenStyles.scaffoldBackground,
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
                voucherController: _voucherCoordinator.controller,
                appliedVoucher: _voucherCoordinator.appliedVoucher,
                isValidatingVoucher: _voucherCoordinator.isValidating,
                voucherError: _voucherCoordinator.voucherError,
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
