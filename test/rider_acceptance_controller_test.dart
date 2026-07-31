import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_acceptance.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'support/rider_acceptance_fixture.dart';
import 'support/rider_test_models.dart';

void main() {
  test('same Rider duplicate taps issue one repository command', () async {
    final repository = _CountingRepository();
    final controller = await _readyController(repository);
    addTearDown(controller.dispose);

    final first = controller.accept(
      requestId: 'delivery-1',
      riderId: 'rider-a',
    );
    final second = controller.accept(
      requestId: 'delivery-1',
      riderId: 'rider-a',
    );
    final results = await Future.wait([first, second]);

    expect(repository.acceptCalls, 1);
    expect(results.every((result) => result.isSuccess), isTrue);
    expect(controller.isAcceptingRequest('delivery-1'), isFalse);
  });

  test(
    'backend eligibility change does not create local active state',
    () async {
      final repository = _CountingRepository();
      final controller = await _readyController(repository);
      addTearDown(controller.dispose);
      repository.setAuthoritativeRiderState(
        acceptanceRider(availability: RiderAvailability.offline),
      );

      final result = await controller.accept(
        requestId: 'delivery-1',
        riderId: 'rider-a',
      );

      expect(result.failure, DeliveryAcceptanceFailure.riderOffline);
      expect(controller.activeDelivery, isNull);
      expect(controller.status.availability, RiderAvailability.onlineAvailable);
      expect(repository.activeDeliveryFor('rider-a'), isNull);
    },
  );

  test('network timeout does not create false local active delivery', () async {
    final repository = _TimeoutRepository();
    final controller = await _readyController(
      repository,
      timeout: const Duration(milliseconds: 10),
    );
    addTearDown(controller.dispose);

    final result = await controller.accept(
      requestId: 'delivery-1',
      riderId: 'rider-a',
    );

    expect(result.failure, DeliveryAcceptanceFailure.networkTimeout);
    expect(controller.activeDelivery, isNull);
    expect(controller.status.availability, RiderAvailability.onlineAvailable);
    expect(controller.isAcceptingRequest('delivery-1'), isFalse);
  });

  test('successful acceptance updates local active and Rider status', () async {
    final repository = _CountingRepository();
    final controller = await _readyController(repository);
    addTearDown(controller.dispose);

    final result = await controller.accept(
      requestId: 'delivery-1',
      riderId: 'rider-a',
    );

    expect(result.isSuccess, isTrue);
    expect(controller.activeDelivery?.requestId, 'delivery-1');
    expect(controller.status.availability, RiderAvailability.deliveryReserved);
    expect(
      controller.requests.where((request) => request.isAssignedTo('rider-a')),
      hasLength(1),
    );
  });
}

Future<RiderDeliveryController> _readyController(
  InMemoryRiderDeliveryRepository repository, {
  Duration timeout = const Duration(seconds: 2),
}) async {
  final controller = RiderDeliveryController(
    repository: repository,
    acceptanceTimeout: timeout,
  )..updateProfile(verifiedRiderProfile());
  controller.setOnline(true);
  controller.updateRequestEnvironment(
    state: RiderRequestAccessState.eligible,
    location: const RiderDeliverySearch(latitude: 8.48, longitude: 124.65),
    accuracyMeters: 5,
  );
  await controller.load(riderId: 'rider-a');
  return controller;
}

class _CountingRepository extends InMemoryRiderDeliveryRepository {
  _CountingRepository()
    : super(
        requests: [acceptanceRequest()],
        riderStates: [acceptanceRider()],
        clock: _clock,
      );

  int acceptCalls = 0;

  @override
  Future<DeliveryAcceptanceReceipt> acceptDelivery(
    DeliveryAcceptanceCommand command,
  ) {
    acceptCalls++;
    return super.acceptDelivery(command);
  }
}

class _TimeoutRepository extends InMemoryRiderDeliveryRepository {
  _TimeoutRepository()
    : super(
        requests: [acceptanceRequest()],
        riderStates: [acceptanceRider()],
        clock: _clock,
      );

  final Completer<DeliveryAcceptanceReceipt> pending = Completer();

  @override
  Future<DeliveryAcceptanceReceipt> acceptDelivery(
    DeliveryAcceptanceCommand command,
  ) => pending.future;
}

DateTime _clock() => acceptanceNow;
