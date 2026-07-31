import 'package:agresell_app/core/theme/agrisellTheme.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_request_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('delivery request identifies pickup and destination addresses', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: RiderDeliveryRequestCard(
              request: _request,
              canAccept: false,
              onAccept: null,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Pick up from: Carmen Public Market'), findsOneWidget);
    expect(find.text('Deliver to: Uptown Fresh Mart'), findsOneWidget);
  });
}

final _request = DeliveryRequest(
  id: 'delivery-1',
  orderNumber: 'AGR-001',
  productName: 'Fresh Tomatoes',
  sellerName: 'Maria Vegetable Farm',
  buyerName: 'Uptown Buyer',
  pickupLocation: const DeliveryLocation(address: 'Carmen Public Market'),
  deliveryLocation: const DeliveryLocation(address: 'Uptown Fresh Mart'),
  pickupDeadline: DateTime(2026, 7, 13),
);
