import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_request_card.dart';
import 'support/rider_test_models.dart';

void main() {
  testWidgets('fallback requests disclose registered-location estimates', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RiderDeliveryRequestCard(
            request: _request(),
            canAccept: false,
            onAccept: null,
            pickupDistanceKm: 2.1,
            pickupTravelMinutes: 11,
            usesRegisteredLocationEstimate: true,
          ),
        ),
      ),
    );

    expect(
      find.text('Estimated from your registered service location'),
      findsOneWidget,
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
  });

  test(
    'GPS-unavailable preview keeps the request but blocks acceptance',
    () async {
      final controller = RiderDeliveryController(
        repository: InMemoryRiderDeliveryRepository(requests: [_request()]),
      )..updateProfile(verifiedRiderProfile());
      addTearDown(controller.dispose);
      controller.setOnline(true);
      controller.updateRequestEnvironment(
        state: RiderRequestAccessState.locationUnavailable,
        accuracyMeters: null,
      );

      await controller.load(riderId: 'rider-a');

      expect(controller.requests.map((item) => item.id), ['location-request']);
      expect(controller.usesRegisteredLocationEstimate, isTrue);
      expect(controller.canAcceptRequest('location-request'), isFalse);
    },
  );
}

DeliveryRequest _request() {
  final now = DateTime.now();
  return DeliveryRequest(
    id: 'location-request',
    orderNumber: 'AGR-location',
    productName: 'Tomatoes',
    sellerName: 'Farm',
    buyerName: 'Buyer',
    pickupLocation: const DeliveryLocation(
      address: 'Cagayan de Oro',
      latitude: 8.49,
      longitude: 124.65,
    ),
    deliveryLocation: const DeliveryLocation(address: 'Buyer address'),
    pickupDeadline: now.add(const Duration(hours: 2)),
    deliveryDeadline: now.add(const Duration(hours: 4)),
    expiresAt: now.add(const Duration(hours: 1)),
    serviceArea: 'Cagayan de Oro',
    totalWeightKg: 10,
    distanceKm: 2,
    estimatedTravelMinutes: 10,
    pickupToDeliveryDistanceKm: 4,
    pickupToDeliveryMinutes: 20,
  );
}
