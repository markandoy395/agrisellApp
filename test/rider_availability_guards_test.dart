import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_availability_state.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_dashboard_state.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_availability_controller.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_location_controller.dart';

import 'support/rider_availability_fakes.dart';
import 'support/rider_test_models.dart';

part 'rider_availability_environment_cases.dart';

void main() {
  registerRiderAvailabilityEnvironmentCases();

  test('poor GPS accuracy warns but allows going online', () async {
    final harness = await _Harness.create(accuracyMeters: 85);
    addTearDown(harness.dispose);

    final result = await harness.availability.setOnline(true);

    expect(result.isSuccess, isTrue);
    expect(harness.availability.gpsStatus, RiderGpsStatus.poorAccuracy);
    expect(
      harness.availability.warning,
      RiderAvailabilityWarning.poorGpsAccuracy,
    );
  });

  test('active delivery prevents an incorrect Offline status', () async {
    final request = assignedDeliveryRequest();
    final delivery = RiderDeliveryController(
      repository: InMemoryRiderDeliveryRepository(requests: [request]),
    )..updateProfile(verifiedRiderProfile());
    delivery.setOnline(true);
    await delivery.load(riderId: 'rider-a');
    await delivery.applyAuthoritativeAvailability(
      RiderAvailability.deliveryReserved,
      loadRequests: false,
    );
    final repository = FakeRiderAvailabilityRepository(
      serverStatus: RiderAvailability.onlineAvailable,
    );
    final connectivity = FakeRiderConnectivityService();
    final location = FakeRiderLocationController();
    final availability = RiderAvailabilityController(
      deliveryController: delivery,
      locationController: location,
      repository: repository,
      connectivityService: connectivity,
    );
    addTearDown(availability.dispose);
    addTearDown(connectivity.dispose);
    addTearDown(location.dispose);
    addTearDown(delivery.dispose);
    await availability.initialize(riderId: 'rider-a');
    expect(repository.serverStatus, RiderAvailability.deliveryReserved);

    final result = await availability.setOnline(false);

    expect(result.isSuccess, isFalse);
    expect(result.warning, RiderAvailabilityWarning.activeDelivery);
    expect(delivery.status.availability, RiderAvailability.deliveryReserved);
    expect(repository.saveCalls, 1);
  });

  test('reconnection restores authoritative server status', () async {
    final harness = await _Harness.create(
      isOnline: false,
      serverStatus: RiderAvailability.onBreak,
    );
    addTearDown(harness.dispose);
    expect(harness.delivery.status.availability, RiderAvailability.offline);

    harness.connectivity.emit(true);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(harness.delivery.status.availability, RiderAvailability.onBreak);
    expect(harness.repository.loadCalls, 1);
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
    RiderLocationState locationState = RiderLocationState.ready,
    double accuracyMeters = 5,
    bool isOnline = true,
    RiderInternetStatus? connectivityStatus,
    RiderAvailability serverStatus = RiderAvailability.offline,
  }) async {
    final delivery = RiderDeliveryController()
      ..updateProfile(verifiedRiderProfile());
    await delivery.load(riderId: 'rider-a');
    final repository = FakeRiderAvailabilityRepository(
      serverStatus: serverStatus,
    );
    final connectivity = FakeRiderConnectivityService(
      isOnline: isOnline,
      status: connectivityStatus,
    );
    final location = FakeRiderLocationController(
      fakeState: locationState,
      accuracyMeters: accuracyMeters,
    );
    final availability = RiderAvailabilityController(
      deliveryController: delivery,
      locationController: location,
      repository: repository,
      connectivityService: connectivity,
      reconnectCheckInterval: Duration.zero,
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
