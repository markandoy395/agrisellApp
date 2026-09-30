import 'support/home_product_fixture.dart';
import 'package:agresell_app/features/shared/orders/data/order_local_repository.dart';
import 'package:agresell_app/features/shared/orders/data/order_repository.dart';
import 'package:agresell_app/features/shared/orders/domain/order_status.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/domain/basket_cart_item.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final basketController = BasketController.instance;
  final orderController = OrderController.instance;

  setUp(() {
    basketController.clear();
    orderController.clear();
  });

  tearDown(() {
    basketController.clear();
    orderController.clear();
  });

  test('placeToShipOrder snapshots selected basket items', () async {
    basketController.addProduct(testHomeProducts[0], quantity: 2);
    basketController.addProduct(testHomeProducts[1], quantity: 1);

    final order = await orderController.placeToShipOrder(
      items: basketController.selectedItems,
      deliveryAddress: 'Test address',
      phoneNumber: 'Test phone',
    );

    expect(order, isNotNull);
    expect(orderController.toShipOrders, hasLength(1));
    expect(orderController.countForLabel('To Ship'), 1);
    expect(orderController.countForLabel('To Pay'), 0);
    expect(order!.status, PlacedOrderStatus.toShip);
    expect(order.totalQuantity, 3);
    expect(order.total, 65);
    expect(order.items.first.productName, testHomeProducts[0].name);
    expect(order.deliveryAddress, 'Test address');
    expect(order.phoneNumber, 'Test phone');
    expect(order.acceptanceExpiresAt, isNotNull);
  });

  test('cancelOrder moves cancellable orders to Cancelled', () async {
    basketController.addProduct(testHomeProducts[0]);

    final order = await orderController.placeToShipOrder(
      items: basketController.selectedItems,
      deliveryAddress: 'Test address',
      phoneNumber: 'Test phone',
    );

    await orderController.cancelOrder(order!.id);

    expect(orderController.toShipOrders, isEmpty);
    expect(
      orderController.ordersForStatus(PlacedOrderStatus.cancelled),
      hasLength(1),
    );
    expect(orderController.countForLabel('Cancelled'), 1);
  });

  test('active farmer reservation count follows actionable orders', () async {
    basketController.addProduct(testHomeProducts[0]);
    final order = await orderController.placeToShipOrder(
      items: basketController.selectedItems,
      deliveryAddress: 'Test address',
      phoneNumber: 'Test phone',
    );

    expect(orderController.activeFarmerReservationCount, 1);
    await orderController.cancelOrder(order!.id);
    expect(orderController.activeFarmerReservationCount, 0);
  });

  test('farmer cannot move an order to shipping before rider pickup', () async {
    basketController.addProduct(testHomeProducts[0]);
    final order = (await orderController.placeToShipOrder(
      items: basketController.selectedItems,
      deliveryAddress: 'Test address',
      phoneNumber: 'Test phone',
    ))!;

    await orderController.acceptOrder(order.id);
    expect(orderController.orders.single.status, PlacedOrderStatus.preparing);
    expect(
      orderController.ordersForFilter(OrderTrackingFilter.toShip),
      hasLength(1),
    );

    await orderController.markReadyForPickup(order.id);
    expect(
      orderController.orders.single.status,
      PlacedOrderStatus.readyForPickup,
    );

    expect(
      orderController.orders.single.status,
      PlacedOrderStatus.readyForPickup,
    );
    expect(
      orderController.ordersForFilter(OrderTrackingFilter.toReceive),
      isEmpty,
    );
    expect(orderController.orderNotifications, hasLength(3));
  });

  test('multi-farmer checkout creates seller-scoped orders', () async {
    final first = BasketCartItem.fromProduct(testHomeProducts[0]);
    final second = BasketCartItem.fromProduct(testHomeProducts[1]);
    final orders = await orderController.placeToShipOrders(
      items: [
        _withSeller(first, farmId: 11, sellerName: 'North Farm'),
        _withSeller(second, farmId: 22, sellerName: 'South Farm'),
      ],
      deliveryAddress: 'Test address',
      phoneNumber: 'Test phone',
    );

    expect(orders, hasLength(2));
    expect(
      orders.map((order) => order.id),
      containsAll(<String>[
        '${orders.first.id.substring(0, orders.first.id.lastIndexOf('-'))}-F11',
        '${orders.first.id.substring(0, orders.first.id.lastIndexOf('-'))}-F22',
      ]),
    );
    expect(orders.every((order) => order.items.length == 1), isTrue);
  });

  test('order filters distinguish To Rate from Completed', () {
    final deliveredOrder = PlacedOrder(
      id: 'ORD-RATE',
      status: PlacedOrderStatus.delivered,
      placedAt: DateTime(2026),
      deliveryAddress: 'Test address',
      phoneNumber: 'Test phone',
      items: const [],
    );

    expect(OrderTrackingFilter.toRate.matches(deliveredOrder), isTrue);

    final completedOrder = deliveredOrder.copyWith(isRated: true);

    expect(OrderTrackingFilter.toRate.matches(completedOrder), isFalse);
    expect(OrderTrackingFilter.completed.matches(completedOrder), isTrue);
  });

  test('placed orders reload after the controller is recreated', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = OrderLocalRepository(preferences: preferences);
    final firstController = OrderController(repository: repository);
    await firstController.loadForAccount('buyer-1');

    final savedOrder = await firstController.placeToShipOrder(
      items: [BasketCartItem.fromProduct(testHomeProducts.first)],
      deliveryAddress: 'Persistent address',
      phoneNumber: '09123456789',
    );

    final restoredController = OrderController(repository: repository);
    await restoredController.loadForAccount('buyer-1');

    expect(savedOrder, isNotNull);
    expect(restoredController.orders, hasLength(1));
    expect(restoredController.orders.single.id, savedOrder!.id);
    expect(
      restoredController.orders.single.deliveryAddress,
      'Persistent address',
    );
    expect(
      restoredController.orders.single.items.single.productName,
      testHomeProducts.first.name,
    );
  });

  test('new checkout persists only its new orders remotely', () async {
    final staleOrder = PlacedOrder(
      id: 'ORD-STALE',
      status: PlacedOrderStatus.cancelled,
      placedAt: DateTime(2026),
      deliveryAddress: 'Old address',
      phoneNumber: '09123456789',
      items: const [],
    );
    final repository = _PlacementRepository(staleOrder);
    final controller = OrderController(repository: repository);
    await controller.loadForAccount('buyer-1');

    final order = await controller.placeToShipOrder(
      items: [BasketCartItem.fromProduct(testHomeProducts.first)],
      deliveryAddress: 'New address',
      phoneNumber: '09987654321',
    );

    expect(order, isNotNull);
    expect(repository.saveCalls, 0);
    expect(repository.createdOrders, hasLength(1));
    expect(repository.createdOrders.single.id, order!.id);
    expect(repository.currentOrders, hasLength(2));
    expect(repository.currentOrders.first.id, order.id);
    expect(repository.currentOrders.last.id, staleOrder.id);
  });
}

class _PlacementRepository implements OrderRepository {
  _PlacementRepository(this.staleOrder);

  final PlacedOrder staleOrder;
  var saveCalls = 0;
  List<PlacedOrder> createdOrders = const [];
  List<PlacedOrder> currentOrders = const [];

  @override
  Future<void> submitFeedback({
    required String accountId,
    required String orderId,
    required String productId,
    int? productRating,
    required String productComment,
    int? riderRating,
    String riderComment = '',
  }) async {}

  @override
  Future<List<PlacedOrder>> load(String accountId) async => [staleOrder];

  @override
  Future<void> createOrders({
    required String accountId,
    required Iterable<PlacedOrder> newOrders,
    required Iterable<PlacedOrder> currentOrders,
  }) async {
    createdOrders = List<PlacedOrder>.of(newOrders);
    this.currentOrders = List<PlacedOrder>.of(currentOrders);
  }

  @override
  Future<void> save(String accountId, Iterable<PlacedOrder> orders) async {
    saveCalls++;
  }

  @override
  Future<void> markReadyForPickup({
    required String accountId,
    required String orderId,
  }) async {}

  @override
  Future<void> recordGcashRefund({
    required String accountId,
    required String orderId,
    required String reference,
  }) async {}

  @override
  Future<void> resubmitGcashReference({
    required String accountId,
    required String orderId,
    required String reference,
  }) async {}

  @override
  Future<void> reviewGcashPayment({
    required String accountId,
    required String orderId,
    required bool approved,
  }) async {}

  @override
  Future<void> reportOrderDispute({
    required String accountId,
    required String orderId,
    required String category,
    required String reason,
    required String requestedResolution,
  }) async {}
}

BasketCartItem _withSeller(
  BasketCartItem item, {
  required int farmId,
  required String sellerName,
}) => BasketCartItem(
  productId: item.productId,
  productName: item.productName,
  image: item.image,
  imageUrl: item.imageUrl,
  sellerName: sellerName,
  sellerLocation: item.sellerLocation,
  harvestDate: item.harvestDate,
  availableWeight: item.availableWeight,
  priceLabel: item.priceLabel,
  pricePerKg: item.pricePerKg,
  unit: item.unit,
  quantity: item.quantity,
  isSelected: item.isSelected,
  farmId: farmId,
);
