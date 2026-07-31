import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_update.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_arrival_validation.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_location.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';

void main() {
  final now = DateTime.now();
  const target = DeliveryLocation(
    address: 'Farm',
    latitude: 8.48,
    longitude: 124.65,
  );

  test('arrival radius, accuracy, freshness, and mock checks are enforced', () {
    expect(_validate(_location(now), target, now).isValid, isTrue);
    expect(
      _validate(_location(now, latitude: 8.50), target, now).isValid,
      isFalse,
    );
    expect(
      _validate(_location(now, accuracy: 80), target, now).isValid,
      isFalse,
    );
    expect(
      _validate(
        _location(now.subtract(const Duration(minutes: 2))),
        target,
        now,
      ).isValid,
      isFalse,
    );
    expect(
      _validate(_location(now, mocked: true), target, now).isValid,
      isFalse,
    );
  });

  test('manual override requires evidence matching the selected reason', () {
    final inaccurate = validateRiderArrival(
      location: _location(now, accuracy: 80),
      target: target,
      radiusMeters: 120,
      maxAccuracyMeters: 50,
      manualOverrideReason: 'location_inaccurate',
      now: now,
    );
    final wrongPin = validateRiderArrival(
      location: _location(now, latitude: 8.50),
      target: target,
      radiusMeters: 120,
      maxAccuracyMeters: 50,
      manualOverrideReason: 'pickup_pin_incorrect',
      now: now,
    );
    final unnecessary = validateRiderArrival(
      location: _location(now),
      target: target,
      radiusMeters: 120,
      maxAccuracyMeters: 50,
      manualOverrideReason: 'pickup_pin_incorrect',
      now: now,
    );
    final otherWithoutNotes = validateRiderArrival(
      location: _location(now, latitude: 8.50),
      target: target,
      radiusMeters: 120,
      maxAccuracyMeters: 50,
      manualOverrideReason: 'other',
      now: now,
    );

    expect(inaccurate.isValid, isTrue);
    expect(wrongPin.isValid, isTrue);
    expect(unnecessary.isValid, isFalse);
    expect(otherWithoutNotes.isValid, isFalse);
  });

  test(
    'delivery controller uses live device evidence, not profile coordinates',
    () {
      final controller = RiderDeliveryController();
      addTearDown(controller.dispose);
      controller.updateCurrentRiderLocation(
        RiderLocation(
          latitude: 8.481,
          longitude: 124.651,
          accuracyMeters: 9,
          altitudeMeters: 12,
          speedMetersPerSecond: 3,
          headingDegrees: 45,
          timestamp: now,
        ),
      );

      final evidence = controller.currentRiderLocation;
      expect(evidence?.latitude, 8.481);
      expect(evidence?.accuracyMeters, 9);
      expect(evidence?.timestamp, now);
      expect(evidence?.altitudeMeters, 12);
    },
  );
}

RiderArrivalValidation _validate(
  DeliveryStatusLocation location,
  DeliveryLocation target,
  DateTime now,
) => validateRiderArrival(
  location: location,
  target: target,
  radiusMeters: 120,
  maxAccuracyMeters: 50,
  now: now,
);

DeliveryStatusLocation _location(
  DateTime timestamp, {
  double latitude = 8.48,
  double accuracy = 8,
  bool mocked = false,
}) => DeliveryStatusLocation(
  latitude: latitude,
  longitude: 124.65,
  accuracyMeters: accuracy,
  timestamp: timestamp,
  isMocked: mocked,
);
