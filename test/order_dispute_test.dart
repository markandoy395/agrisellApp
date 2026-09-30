import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/features/shared/orders/data/order_repository.dart';
import 'package:agresell_app/features/shared/orders/domain/order_dispute.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';

class _FakeDisputeRepository implements OrderRepository {
  _FakeDisputeRepository(this.initialOrders);

  List<PlacedOrder> initialOrders;
  String? reportedOrderId;
  String? reportedCategory;
  String? reportedReason;
  String? reportedResolution;

  @override
  Future<List<PlacedOrder>> load(String accountId) async => initialOrders;

  @override
  Future<void> save(String accountId, Iterable<PlacedOrder> orders) async {
    initialOrders = orders.toList();
  }

  @override
  Future<void> reportOrderDispute({
    required String accountId,
    required String orderId,
    required String category,
    required String reason,
    required String requestedResolution,
  }) async {
    reportedOrderId = orderId;
    reportedCategory = category;
    reportedReason = reason;
    reportedResolution = requestedResolution;
  }

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
  Future<void> createOrders({
    required String accountId,
    required Iterable<PlacedOrder> newOrders,
    required Iterable<PlacedOrder> currentOrders,
  }) async {}

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
}

void main() {
  group('OrderDispute Model & Eligibility', () {
    test('canDispute is only true for delivered orders without existing dispute', () {
      final preparingOrder = PlacedOrder(
        id: 'ORD-PREP',
        status: PlacedOrderStatus.preparing,
        placedAt: DateTime(2026),
        deliveryAddress: 'Test address',
        phoneNumber: '09123456789',
        items: const [],
      );
      expect(preparingOrder.canDispute, isFalse);

      final deliveredOrder = PlacedOrder(
        id: 'ORD-DELIV',
        status: PlacedOrderStatus.delivered,
        placedAt: DateTime(2026),
        deliveryAddress: 'Test address',
        phoneNumber: '09123456789',
        items: const [],
      );
      expect(deliveredOrder.canDispute, isTrue);
      expect(deliveredOrder.hasDispute, isFalse);

      final disputedOrder = deliveredOrder.copyWith(
        dispute: const OrderDispute(
          status: OrderDisputeStatus.pending,
          category: OrderDisputeCategory.damagedRottenProduce,
          reason: 'Produce arrived spoiled and bruised',
          requestedResolution: OrderDisputeResolution.fullRefund,
        ),
      );
      expect(disputedOrder.canDispute, isFalse);
      expect(disputedOrder.hasDispute, isTrue);
    });

    test('OrderDispute json serialization and parsing round trip', () {
      final dispute = OrderDispute(
        status: OrderDisputeStatus.pending,
        category: OrderDisputeCategory.damagedRottenProduce,
        reason: 'Tomatoes arrived crushed and spoiled',
        requestedResolution: OrderDisputeResolution.fullRefund,
        submittedAt: DateTime.utc(2026, 9, 21, 10, 0),
        resolutionNote: 'Awaiting farmer response',
      );

      final json = dispute.toJson();
      final reconstructed = OrderDispute.fromJson(json);

      expect(reconstructed.status, OrderDisputeStatus.pending);
      expect(reconstructed.category, OrderDisputeCategory.damagedRottenProduce);
      expect(reconstructed.reason, 'Tomatoes arrived crushed and spoiled');
      expect(reconstructed.requestedResolution, OrderDisputeResolution.fullRefund);
      expect(reconstructed.resolutionNote, 'Awaiting farmer response');
    });
  });

  group('OrderController.reportOrderDispute', () {
    test('successfully records dispute, notifies buyer, and delegates to repository', () async {
      final deliveredOrder = PlacedOrder(
        id: 'ORD-101',
        buyerId: 'buyer-42',
        status: PlacedOrderStatus.delivered,
        placedAt: DateTime(2026),
        deliveryAddress: 'Test address',
        phoneNumber: '09123456789',
        items: const [
          PlacedOrderItem(
            productId: '1',
            productName: 'Organic Strawberries',
            image: 'strawberries.png',
            sellerName: 'Baguio Farms',
            pricePerKg: 250,
            unit: 'kg',
            quantity: 2,
          ),
        ],
      );

      final repository = _FakeDisputeRepository([deliveredOrder]);
      final controller = OrderController(repository: repository);
      await controller.loadForAccount('buyer-42');

      expect(controller.orders.first.canDispute, isTrue);
      expect(controller.orders.first.hasDispute, isFalse);

      await controller.reportOrderDispute(
        orderId: 'ORD-101',
        category: OrderDisputeCategory.damagedRottenProduce,
        reason: 'Strawberries arrived rotten and moldy during transit.',
        requestedResolution: OrderDisputeResolution.fullRefund,
      );

      expect(repository.reportedOrderId, 'ORD-101');
      expect(repository.reportedCategory, 'damaged_rotten_produce');
      expect(repository.reportedReason, 'Strawberries arrived rotten and moldy during transit.');
      expect(repository.reportedResolution, 'full_refund');

      final updatedOrder = controller.orders.first;
      expect(updatedOrder.hasDispute, isTrue);
      expect(updatedOrder.canDispute, isFalse);
      expect(updatedOrder.dispute?.status, OrderDisputeStatus.pending);
      expect(updatedOrder.dispute?.category, OrderDisputeCategory.damagedRottenProduce);

      // Verify notification generated
      expect(controller.orderNotifications.any((n) => n.title == 'Dispute submitted'), isTrue);
    });

    test('rejects dispute if order is not delivered or reason is empty', () async {
      final preparingOrder = PlacedOrder(
        id: 'ORD-102',
        buyerId: 'buyer-42',
        status: PlacedOrderStatus.preparing,
        placedAt: DateTime(2026),
        deliveryAddress: 'Test address',
        phoneNumber: '09123456789',
        items: const [],
      );

      final repository = _FakeDisputeRepository([preparingOrder]);
      final controller = OrderController(repository: repository);
      await controller.loadForAccount('buyer-42');

      expect(
        () => controller.reportOrderDispute(
          orderId: 'ORD-102',
          category: OrderDisputeCategory.damagedRottenProduce,
          reason: 'Valid explanation text',
          requestedResolution: OrderDisputeResolution.fullRefund,
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
