import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_acceptance.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_request_query.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'support/rider_test_models.dart';
import 'support/rider_acceptance_fixture.dart';

void main() {
  test('search is debounced and does not query on every keystroke', () async {
    final repository = _CountingRepository([_request('a')]);
    final controller = _readyController(repository);
    addTearDown(controller.dispose);
    await controller.load(riderId: 'rider-a');
    final baseline = repository.nearbyCalls;

    controller.setSearchText('t');
    controller.setSearchText('to');
    controller.setSearchText('tomato');
    await Future<void>.delayed(const Duration(milliseconds: 400));

    expect(repository.nearbyCalls, baseline + 1);
  });

  test('an older response cannot overwrite a newer request query', () async {
    final repository = _QueuedRepository();
    final controller = _readyController(repository);
    addTearDown(controller.dispose);

    final oldLoad = controller.load(riderId: 'rider-a');
    await Future<void>.delayed(Duration.zero);
    controller.setRequestSort(RiderRequestSort.highestEarning);
    await Future<void>.delayed(Duration.zero);

    repository.complete(1, [_request('new')]);
    await Future<void>.delayed(Duration.zero);
    repository.complete(0, [_request('old')]);
    await oldLoad;
    await Future<void>.delayed(Duration.zero);

    expect(controller.requests.map((item) => item.id), ['new']);
  });

  test('pagination merges by request ID without duplicates', () async {
    final repository = _PagedRepository();
    final controller = _readyController(repository);
    addTearDown(controller.dispose);
    await controller.load(riderId: 'rider-a');
    await controller.loadMoreRequests();

    expect(controller.requests.map((item) => item.id).toSet(), {'a', 'b'});
    expect(controller.requests, hasLength(2));
  });

  test('real-time invalidation removes a request assigned elsewhere', () async {
    final repository = InMemoryRiderDeliveryRepository(
      requests: [_request('a')],
      riderStates: [acceptanceRider(id: 'rider-b')],
    );
    final controller = _readyController(repository);
    addTearDown(controller.dispose);
    await controller.load(riderId: 'rider-a');
    expect(controller.requests, hasLength(1));

    await repository.acceptDelivery(
      const DeliveryAcceptanceCommand(
        requestId: 'a',
        riderId: 'rider-b',
        idempotencyKey: 'assign-elsewhere',
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 350));

    expect(controller.requests, isEmpty);
  });
}

RiderDeliveryController _readyController(RiderDeliveryRepository repository) {
  final controller = RiderDeliveryController(repository: repository)
    ..updateProfile(verifiedRiderProfile())
    ..setOnline(true)
    ..updateRequestEnvironment(
      state: RiderRequestAccessState.eligible,
      location: const RiderDeliverySearch(latitude: 8.48, longitude: 124.65),
      accuracyMeters: 5,
    );
  return controller;
}

class _CountingRepository extends InMemoryRiderDeliveryRepository {
  _CountingRepository(List<DeliveryRequest> requests)
    : super(requests: requests);
  int nearbyCalls = 0;

  @override
  Future<RiderRequestPage> fetchNearbyRequests(RiderRequestQuery query) {
    nearbyCalls++;
    return super.fetchNearbyRequests(query);
  }
}

class _QueuedRepository extends InMemoryRiderDeliveryRepository {
  _QueuedRepository() : super(requests: const []);
  final List<Completer<RiderRequestPage>> calls = [];

  @override
  Future<RiderRequestPage> fetchNearbyRequests(RiderRequestQuery query) {
    final completer = Completer<RiderRequestPage>();
    calls.add(completer);
    return completer.future;
  }

  void complete(int index, List<DeliveryRequest> requests) {
    calls[index].complete(RiderRequestPage(items: requests));
  }
}

class _PagedRepository extends InMemoryRiderDeliveryRepository {
  _PagedRepository() : super(requests: const []);

  @override
  Future<RiderRequestPage> fetchNearbyRequests(RiderRequestQuery query) async {
    return query.cursor == null
        ? RiderRequestPage(items: [_request('a')], nextCursor: 'next')
        : RiderRequestPage(items: [_request('a'), _request('b')]);
  }
}

DeliveryRequest _request(String id) {
  final now = DateTime.now();
  return DeliveryRequest(
    id: id,
    orderNumber: 'AGR-$id',
    productName: 'Tomatoes $id',
    sellerName: 'Farm',
    buyerName: 'Buyer',
    pickupLocation: const DeliveryLocation(address: 'Carmen'),
    deliveryLocation: const DeliveryLocation(address: 'Uptown'),
    pickupDeadline: now.add(const Duration(hours: 1)),
    deliveryDeadline: now.add(const Duration(hours: 2)),
    expiresAt: now.add(const Duration(minutes: 50)),
    serviceArea: 'Cagayan de Oro',
    totalWeightKg: 20,
    distanceKm: 2,
    estimatedTravelMinutes: 10,
    pickupToDeliveryDistanceKm: 4,
    pickupToDeliveryMinutes: 20,
  );
}
