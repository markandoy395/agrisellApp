import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_tabs.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_batch_delivery_summary.dart';
import 'support/rider_batch_fixture.dart';

void main() {
  testWidgets(
    'Active tab shows batch route, capacity, deadlines, and earnings',
    (tester) async {
      tester.view.physicalSize = const Size(430, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = InMemoryRiderDeliveryRepository(
        requests: [
          batchRequest(
            id: 'a',
            earning: 100,
            stage: DeliveryStage.accepted,
            assignedRiderId: 'rider-a',
          ),
          batchRequest(
            id: 'b',
            earning: 140,
            pickupLatitude: 8.482,
            deliveryLatitude: 8.5,
            stage: DeliveryStage.accepted,
            assignedRiderId: 'rider-a',
          ),
        ],
      );
      final controller = RiderDeliveryController(repository: repository)
        ..updateProfile(batchRiderProfile());
      addTearDown(controller.dispose);
      await controller.applyAuthoritativeAvailability(
        RiderAvailability.deliveryReserved,
        loadRequests: false,
      );
      await controller.load(riderId: 'rider-a');
      await controller.refreshActiveDelivery();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RiderActiveDeliveryList(
              controller: controller,
              riderId: 'rider-a',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Route and handling details'));
      await tester.pumpAndSettle();
      expect(find.text('2-delivery batch'), findsOneWidget);
      expect(find.textContaining('Total route:'), findsOneWidget);
      expect(
        find.textContaining('Combined earning: PHP 240.00'),
        findsOneWidget,
      );
      expect(find.textContaining('Capacity left: 60.0 kg'), findsOneWidget);
      expect(find.textContaining('Pickup sequence:'), findsOneWidget);
      expect(find.textContaining('Delivery sequence:'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(RiderBatchDeliverySummary),
          matching: find.textContaining('deadline'),
        ),
        findsNWidgets(2),
      );
      expect(controller.activeDeliveryRequests, hasLength(2));
      await tester.scrollUntilVisible(find.text('Product b'), 300);
      expect(find.text('Product b'), findsOneWidget);
      expect(find.text('Manage delivery'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
}
