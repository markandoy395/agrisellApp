import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agresell_app/features/rider/dashboard/data/temporary_local_rider_availability_repository.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_availability_state.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_availability_controller.dart';
import 'package:agresell_app/features/rider/deliveries/data/shared_preferences_rider_delivery_state_store.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'support/rider_availability_fakes.dart';
import 'support/rider_test_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('offline Rider synchronizes Online and Available', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);

    final result = await harness.availability.setOnline(true);

    expect(result.isSuccess, isTrue);
    expect(harness.repository.saveCalls, 1);
    expect(harness.repository.serverStatus, RiderAvailability.onlineAvailable);
    expect(
      harness.delivery.status.availability,
      RiderAvailability.onlineAvailable,
    );
  });

  test('online Rider synchronizes Offline', () async {
    final harness = await _Harness.create(
      serverStatus: RiderAvailability.onlineAvailable,
    );
    addTearDown(harness.dispose);

    final result = await harness.availability.setOnline(false);

    expect(result.isSuccess, isTrue);
    expect(harness.repository.serverStatus, RiderAvailability.offline);
    expect(harness.delivery.status.availability, RiderAvailability.offline);
  });

  test('failed synchronization restores the previous UI state', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);
    harness.repository.failSave = true;

    final result = await harness.availability.setOnline(true);

    expect(result.isSuccess, isFalse);
    expect(result.warning, RiderAvailabilityWarning.synchronizationFailed);
    expect(
      harness.availability.displayedAvailability,
      RiderAvailability.offline,
    );
    expect(harness.delivery.status.availability, RiderAvailability.offline);
  });

  test('repeated toggle taps share one backend update', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);
    final gate = Completer<void>();
    harness.repository.saveGate = gate;

    final first = harness.availability.setOnline(true);
    final second = harness.availability.setOnline(true);
    await Future<void>.delayed(Duration.zero);

    expect(harness.repository.saveCalls, 1);
    expect(harness.availability.isUpdating, isTrue);
    expect(
      harness.availability.displayedAvailability,
      RiderAvailability.offline,
    );
    gate.complete();
    expect((await first).isSuccess, isTrue);
    expect((await second).isSuccess, isTrue);
    expect(harness.repository.saveCalls, 1);
  });

  test('availability survives controller recreation', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = TemporaryLocalRiderAvailabilityRepository(
      preferences: preferences,
    );
    final firstDelivery = RiderDeliveryController(
      stateStore: SharedPreferencesRiderDeliveryStateStore(
        preferences: preferences,
      ),
    )..updateProfile(verifiedRiderProfile());
    await firstDelivery.restore(riderId: 'rider-a');
    final firstLocation = FakeRiderLocationController();
    final firstConnectivity = FakeRiderConnectivityService();
    final firstAvailability = RiderAvailabilityController(
      deliveryController: firstDelivery,
      locationController: firstLocation,
      repository: repository,
      connectivityService: firstConnectivity,
    );
    await firstAvailability.initialize(riderId: 'rider-a');
    expect((await firstAvailability.setOnline(true)).isSuccess, isTrue);
    firstAvailability.dispose();
    firstConnectivity.dispose();
    firstLocation.dispose();
    firstDelivery.dispose();

    final restoredDelivery = RiderDeliveryController(
      stateStore: SharedPreferencesRiderDeliveryStateStore(
        preferences: preferences,
      ),
    )..updateProfile(verifiedRiderProfile());
    addTearDown(restoredDelivery.dispose);
    expect(await restoredDelivery.restore(riderId: 'rider-a'), isTrue);
    final location = FakeRiderLocationController();
    final connectivity = FakeRiderConnectivityService();
    final restoredAvailability = RiderAvailabilityController(
      deliveryController: restoredDelivery,
      locationController: location,
      repository: repository,
      connectivityService: connectivity,
    );
    addTearDown(restoredAvailability.dispose);
    addTearDown(connectivity.dispose);
    addTearDown(location.dispose);
    await restoredAvailability.initialize(riderId: 'rider-a');

    expect(
      restoredAvailability.availability,
      RiderAvailability.onlineAvailable,
    );
  });
}

class _Harness {
  _Harness({
    required this.delivery,
    required this.availability,
    required this.repository,
    required this.connectivity,
    required this.location,
  });

  final RiderDeliveryController delivery;
  final RiderAvailabilityController availability;
  final FakeRiderAvailabilityRepository repository;
  final FakeRiderConnectivityService connectivity;
  final FakeRiderLocationController location;

  static Future<_Harness> create({
    RiderAvailability serverStatus = RiderAvailability.offline,
  }) async {
    final delivery = RiderDeliveryController()
      ..updateProfile(verifiedRiderProfile());
    await delivery.load(riderId: 'rider-a');
    final repository = FakeRiderAvailabilityRepository(
      serverStatus: serverStatus,
    );
    final connectivity = FakeRiderConnectivityService();
    final location = FakeRiderLocationController();
    final availability = RiderAvailabilityController(
      deliveryController: delivery,
      locationController: location,
      repository: repository,
      connectivityService: connectivity,
    );
    await availability.initialize(riderId: 'rider-a');
    return _Harness(
      delivery: delivery,
      availability: availability,
      repository: repository,
      connectivity: connectivity,
      location: location,
    );
  }

  void dispose() {
    availability.dispose();
    connectivity.dispose();
    location.dispose();
    delivery.dispose();
  }
}
