import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agresell_app/features/shared/orders/data/order_json_codec.dart';
import 'package:agresell_app/features/shared/orders/data/order_local_repository.dart';
import 'package:agresell_app/features/shared/orders/domain/order_feedback.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'package:agresell_app/features/shared/products/data/product_reviews.dart';

void main() {
  test('order codec preserves payment and feedback evidence', () {
    final order = _order(
      status: PlacedOrderStatus.delivered,
      payment: const OrderPayment(
        method: OrderPaymentMethod.gcash,
        status: OrderPaymentStatus.verified,
        transactionReference: '1234567890123',
        refundReference: 'REFUND-987654',
      ),
      feedback: OrderFeedback(
        rating: 4,
        comment: 'Fresh and carefully packed.',
        submittedAt: DateTime.utc(2026, 7, 29),
      ),
    );

    final restored = OrderJsonCodec.decodeOrder(
      OrderJsonCodec.encodeOrder(order),
    )!;

    expect(restored.payment.method, OrderPaymentMethod.gcash);
    expect(restored.payment.status, OrderPaymentStatus.verified);
    expect(restored.payment.transactionReference, '1234567890123');
    expect(restored.payment.refundReference, 'REFUND-987654');
    expect(restored.feedback?.rating, 4);
    expect(restored.feedback?.comment, 'Fresh and carefully packed.');
  });

  test('feedback is saved with its rating and comment', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = OrderLocalRepository(preferences: preferences);
    await repository.save('buyer-1', [
      _order(status: PlacedOrderStatus.delivered),
    ]);
    final controller = OrderController(repository: repository);
    await controller.loadForAccount('buyer-1');

    await controller.submitFeedback(
      orderId: 'ORD-1',
      rating: 5,
      comment: 'Excellent harvest.',
    );
    final stored = (await repository.load('buyer-1')).single;

    expect(stored.isRated, isTrue);
    expect(stored.feedback?.rating, 5);
    expect(stored.feedback?.comment, 'Excellent harvest.');
  });

  test(
    'unverified GCash blocks acceptance and rejected references recover',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = OrderLocalRepository(preferences: preferences);
      final submitted = OrderPayment.gcash('1111111111111');
      await repository.save('farmer-1', [_order(payment: submitted)]);
      final controller = OrderController(repository: repository);
      await controller.loadForAccount('farmer-1');

      await expectLater(controller.acceptOrder('ORD-1'), throwsStateError);
      await controller.reviewGcashPayment(orderId: 'ORD-1', approved: false);
      expect(
        controller.orders.single.payment.status,
        OrderPaymentStatus.rejected,
      );
      await controller.resubmitGcashReference(
        orderId: 'ORD-1',
        reference: '2222222222222',
      );
      expect(
        controller.orders.single.payment.status,
        OrderPaymentStatus.submittedForVerification,
      );
      expect(
        controller.orders.single.payment.transactionReference,
        '2222222222222',
      );
    },
  );

  test('product review response exposes aggregate and verified reviews', () {
    final summary = ProductReviewRepository.parse({
      'averageRating': 4.5,
      'reviewCount': 2,
      'reviews': [
        {
          'reviewerName': 'Ana D.',
          'rating': 5,
          'comment': 'Very fresh.',
          'submittedAt': '2026-07-29T10:00:00Z',
        },
      ],
    });

    expect(summary.averageRating, 4.5);
    expect(summary.reviewCount, 2);
    expect(summary.reviews.single.reviewerName, 'Ana D.');
    expect(summary.reviews.single.comment, 'Very fresh.');
  });

  test('cancelling verified GCash marks the payment for refund', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = OrderLocalRepository(preferences: preferences);
    await repository.save('buyer-1', [
      _order(
        payment: const OrderPayment(
          method: OrderPaymentMethod.gcash,
          status: OrderPaymentStatus.verified,
          transactionReference: '1234567890123',
        ),
      ),
    ]);
    final controller = OrderController(repository: repository);
    await controller.loadForAccount('buyer-1');

    await controller.cancelOrder('ORD-1');

    expect(controller.orders.single.status, PlacedOrderStatus.cancelled);
    expect(
      controller.orders.single.payment.status,
      OrderPaymentStatus.refundRequired,
    );

    await controller.recordGcashRefund(
      orderId: 'ORD-1',
      reference: 'REFUND-123456',
    );
    expect(
      controller.orders.single.payment.status,
      OrderPaymentStatus.refunded,
    );
    expect(controller.orders.single.payment.refundReference, 'REFUND-123456');
  });
}

PlacedOrder _order({
  PlacedOrderStatus status = PlacedOrderStatus.toShip,
  OrderPayment payment = const OrderPayment.cashOnDelivery(),
  OrderFeedback? feedback,
}) => PlacedOrder(
  id: 'ORD-1',
  status: status,
  placedAt: DateTime.utc(2026, 7, 29),
  deliveryAddress: 'Test address',
  phoneNumber: '09171234567',
  payment: payment,
  feedback: feedback,
  isRated: feedback != null,
  items: const [
    PlacedOrderItem(
      productId: '1',
      productName: 'Tomato',
      image: 'assets/images/vege.jpeg',
      sellerName: 'Test Farmer',
      pricePerKg: 50,
      unit: 'kg',
      quantity: 2,
    ),
  ],
);
