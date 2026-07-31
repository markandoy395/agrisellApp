import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/presentation/rider_availability_presentation.dart';

void main() {
  test('availability backend values round-trip', () {
    for (final availability in RiderAvailability.values) {
      expect(
        RiderAvailability.fromBackendValue(availability.backendValue),
        availability,
      );
      expect(availability.displayLabel, isNotEmpty);
    }
  });

  test('legacy availability aliases map to canonical values', () {
    expect(
      RiderAvailability.fromBackendValue('available'),
      RiderAvailability.onlineAvailable,
    );
    expect(
      RiderAvailability.fromBackendValue('pickingUp'),
      RiderAvailability.goingToPickup,
    );
    expect(
      RiderAvailability.fromBackendValue('delivering'),
      RiderAvailability.goingToBuyer,
    );
  });

  test('only online and available can receive requests', () {
    expect(RiderAvailability.onlineAvailable.canReceiveRequests, isTrue);
    for (final availability in RiderAvailability.values.where(
      (value) => value != RiderAvailability.onlineAvailable,
    )) {
      expect(availability.canReceiveRequests, isFalse);
    }
  });
}
