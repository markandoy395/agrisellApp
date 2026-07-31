import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request_metadata.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_request_card.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_request_detail_sections.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_request_state_card.dart';

void main() {
  testWidgets(
    'request card shows priority, route, earning, and safe disabled accept',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RiderDeliveryRequestCard(
                request: _request(),
                canAccept: false,
                onAccept: null,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Urgent'), findsOneWidget);
      expect(find.text('2.0 km to pickup'), findsOneWidget);
      expect(find.text('PHP 180.00'), findsOneWidget);
      expect(find.text('Accept'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
    },
  );

  testWidgets('pre-assignment details protect the buyer name', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RiderRequestDetailSections(request: _request()),
          ),
        ),
      ),
    );

    expect(find.text('Private Buyer Name'), findsNothing);
    expect(find.text('Buyer destination'), findsOneWidget);
    expect(find.text('Vehicle and handling requirements'), findsOneWidget);
    expect(find.text('Estimated Rider earning'), findsOneWidget);
  });

  testWidgets('environment states explain why requests are unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RiderRequestAccessCard(
          state: RiderRequestAccessState.poorGpsAccuracy,
        ),
      ),
    );
    expect(find.text('Poor GPS accuracy'), findsOneWidget);
    expect(find.textContaining('open area'), findsOneWidget);
  });
}

DeliveryRequest _request() {
  final now = DateTime.now();
  return DeliveryRequest(
    id: 'request-1',
    orderNumber: 'AGR-001',
    productName: 'Fresh Tomatoes',
    productCategory: 'Fresh produce',
    productDescription: 'Packed farm order.',
    sellerName: 'Carmen Farm',
    buyerName: 'Private Buyer Name',
    pickupLocation: const DeliveryLocation(address: 'Carmen Market'),
    deliveryLocation: const DeliveryLocation(address: 'Uptown'),
    pickupDeadline: now.add(const Duration(hours: 1)),
    deliveryDeadline: now.add(const Duration(hours: 3)),
    expiresAt: now.add(const Duration(minutes: 50)),
    serviceArea: 'Cagayan de Oro',
    quantityDescription: '10 crates',
    totalWeightKg: 80,
    distanceKm: 2,
    estimatedTravelMinutes: 10,
    pickupToDeliveryDistanceKm: 5,
    pickupToDeliveryMinutes: 25,
    deliveryFee: 180,
    feeBreakdown: const DeliveryFeeBreakdown(
      baseFee: 100,
      distanceFee: 50,
      weightAdjustment: 20,
      urgencyAdjustment: 10,
    ),
    priority: DeliveryPriority.urgent,
    handlingRequirements: const [
      ProductHandlingRequirement(type: ProductHandlingType.perishable),
    ],
  );
}
