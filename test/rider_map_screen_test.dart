import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_location_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/screens/rider_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('map starts device tracking only after its tab is active', (
    tester,
  ) async {
    final deliveryController = RiderDeliveryController();
    final locationController = _TrackingLocationController();
    addTearDown(deliveryController.dispose);
    addTearDown(locationController.dispose);

    await _pumpMap(
      tester,
      deliveryController: deliveryController,
      locationController: locationController,
      isActive: false,
    );

    expect(locationController.startCalls, 0);

    await _pumpMap(
      tester,
      deliveryController: deliveryController,
      locationController: locationController,
      isActive: true,
    );
    await tester.pump();

    expect(locationController.startCalls, 1);
  });
}

Future<void> _pumpMap(
  WidgetTester tester, {
  required RiderDeliveryController deliveryController,
  required RiderLocationController locationController,
  required bool isActive,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: RiderMapScreen(
        key: const ValueKey('rider-map'),
        profile: null,
        deliveryController: deliveryController,
        locationController: locationController,
        isActive: isActive,
        onOpenList: () {},
      ),
    ),
  );
}

class _TrackingLocationController extends RiderLocationController {
  var startCalls = 0;

  @override
  Future<void> startTracking() async {
    startCalls++;
  }
}
