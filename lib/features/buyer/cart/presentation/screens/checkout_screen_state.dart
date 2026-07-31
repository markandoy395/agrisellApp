part of 'checkout_screen.dart';

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _controller = BasketController.instance;
  final _orderController = OrderController.instance;
  final _profile = currentAuthenticatedUserProfile();
  late final ConfirmedLocationRepository _locationRepository;
  ConfirmedLocation? _deliveryLocation;
  OrderPayment _payment = const OrderPayment.cashOnDelivery();
  int? _gcashFarmId;

  @override
  void initState() {
    super.initState();
    _locationRepository =
        widget.locationRepository ?? ConfirmedLocationRepository();
    unawaited(_restoreDeliveryLocation());
  }

  Future<void> _restoreDeliveryLocation() async {
    final saved = await _locationRepository.load(LocationOwnerRole.buyer);
    if (saved == null || !mounted) return;
    setState(() => _deliveryLocation = saved);
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
      total: _controller.selectedTotal,
      repository: widget.paymentRepository,
    );
    if (selection == null || !mounted) return;
    setState(() {
      _payment = selection.payment;
      _gcashFarmId = selection.farmId;
    });
  }

  Future<void> _placeOrder() async {
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

    final List<PlacedOrder> orders;
    try {
      orders = await _orderController.placeToShipOrders(
        items: selectedItems,
        deliveryAddress: deliveryAddress,
        phoneNumber: _profile.phoneNumber,
        deliveryLatitude: location.latitude,
        deliveryLongitude: location.longitude,
        payment: _payment,
      );
    } on OrderPlacementException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showAppSnackBar(SnackBar(content: Text(error.message)));
      return;
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showAppSnackBar(
        const SnackBar(
          content: Text('The order could not be saved. Please try again.'),
        ),
      );
      return;
    }

    if (orders.isEmpty || !mounted) return;
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
          total: _controller.selectedTotal,
          onPlaceOrder: _placeOrder,
        ),
      ),
      body: Column(
        children: [
          const _CheckoutHeader(),
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
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
