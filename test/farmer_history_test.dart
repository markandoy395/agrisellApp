import 'support/authenticated_test_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/farmer/profile/domain/farmer_history_section.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_history_card.dart';
import 'package:agresell_app/features/shared/orders/data/order_json_codec.dart';
import 'package:agresell_app/features/shared/orders/data/order_snapshot_merger.dart';
import 'package:agresell_app/features/shared/orders/domain/order_feedback.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

void main() {
  configureAuthenticatedTests(role: AuthRole.farmer);
  test('farmer history sections follow actual order workflow status', () {
    expect(
      FarmerHistorySection.confirm.matches(_order(PlacedOrderStatus.toShip)),
      isTrue,
    );
    expect(
      FarmerHistorySection.toShip.matches(_order(PlacedOrderStatus.preparing)),
      isTrue,
    );
    expect(
      FarmerHistorySection.toShip.matches(
        _order(PlacedOrderStatus.readyForPickup),
      ),
      isTrue,
    );
    expect(
      FarmerHistorySection.toShip.matches(_order(PlacedOrderStatus.shipping)),
      isFalse,
    );
    expect(
      FarmerHistorySection.completed.matches(
        _order(PlacedOrderStatus.delivered),
      ),
      isTrue,
    );
    expect(
      FarmerHistorySection.completed.matches(
        _order(PlacedOrderStatus.cancelled),
      ),
      isFalse,
    );
  });

  test('feedback contains only delivered orders with buyer reviews', () {
    final feedback = OrderFeedback(
      rating: 5,
      comment: 'Fresh harvest.',
      submittedAt: DateTime.utc(2026, 8, 10),
    );

    expect(
      FarmerHistorySection.feedback.matches(
        _order(PlacedOrderStatus.delivered, feedback: feedback),
      ),
      isTrue,
    );
    expect(
      FarmerHistorySection.feedback.matches(
        _order(PlacedOrderStatus.delivered),
      ),
      isFalse,
    );
    expect(
      FarmerHistorySection.feedback.matches(
        _order(PlacedOrderStatus.preparing, feedback: feedback),
      ),
      isFalse,
    );
  });

  test('farmer review snapshots populate the feedback section', () {
    final merged = OrderSnapshotMerger.merge(
      [
        {
          'id': 'ORD-REVIEWED',
          'status': 'delivered',
          'placedAt': '2026-08-10T00:00:00Z',
          'deliveryAddress': 'Test address',
          'phoneNumber': '09171234567',
          'items': [
            {
              'productId': '7',
              'productName': 'Tomato',
              'image': 'assets/images/vege.jpeg',
              'sellerName': 'Test Farmer',
              'pricePerKg': 50,
              'unit': 'kg',
              'quantity': 1,
            },
          ],
        },
      ],
      reviews: [
        {
          'orderId': 'ORD-REVIEWED',
          'itemReviews': [
            {
              'productId': '7',
              'rating': 5,
              'comment': 'Fresh harvest.',
              'submittedAt': '2026-08-10T01:00:00Z',
            },
          ],
        },
      ],
    );
    final order = OrderJsonCodec.decodeOrders(merged).single;

    expect(order.items.single.feedback?.rating, 5);
    expect(order.items.single.feedback?.comment, 'Fresh harvest.');
    expect(FarmerHistorySection.feedback.matches(order), isTrue);
  });

  testWidgets('each farmer history shortcut opens its matching tab', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: FarmerHistoryCard())),
    );

    for (final section in FarmerHistorySection.values) {
      await tester.tap(find.text(section.label));
      await tester.pumpAndSettle();

      final tabs = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabs.controller?.index, section.index);

      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  });
}

PlacedOrder _order(PlacedOrderStatus status, {OrderFeedback? feedback}) =>
    PlacedOrder(
      id: 'ORD-${status.name}',
      status: status,
      placedAt: DateTime.utc(2026, 8, 10),
      deliveryAddress: 'Test address',
      phoneNumber: '09171234567',
      items: [
        PlacedOrderItem(
          productId: '1',
          productName: 'Tomato',
          image: 'assets/images/vege.jpeg',
          sellerName: 'Test Farmer',
          pricePerKg: 50,
          unit: 'kg',
          quantity: 1,
          feedback: feedback,
        ),
      ],
    );
