import 'package:flutter_test/flutter_test.dart'; import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart'; import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request_metadata.dart'; import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_request_query.dart'; import 'package:agresell_app/features/rider/profile/domain/rider_registration.dart';
void main() { final now = DateTime.now();
  late InMemoryRiderDeliveryRepository repository; setUp(() {
    repository = InMemoryRiderDeliveryRepository( requests: [
        _request(now, 'a', 'Tomatoes', 2, 120, DeliveryPriority.urgent), _request(now, 'b', 'Rice', 8, 240, DeliveryPriority.scheduled),
        _request(now, 'c', 'Bananas', 4, 160, DeliveryPriority.standard), ],
    ); });
  test('searches supported private-safe fields with pagination', () async { final search = await repository.fetchNearbyRequests(
      _query(searchText: 'AGR-a'), );
    expect(search.items.map((item) => item.id), ['a']); final first = await repository.fetchNearbyRequests(_query(pageSize: 2));
    final second = await repository.fetchNearbyRequests( _query(pageSize: 2, cursor: first.nextCursor),
    ); expect(first.items, hasLength(2));
    expect(second.items, hasLength(1)); expect({
      ...first.items.map((e) => e.id), ...second.items.map((e) => e.id),
    }, hasLength(3)); });
  test('sorts nearest, highest earning, urgent, and shortest trip', () async { expect(await _ids(repository, RiderRequestSort.nearestPickup), [
      'a', 'c',
      'b', ]);
    expect(await _ids(repository, RiderRequestSort.highestEarning), [ 'b',
      'c', 'a',
    ]); expect(await _ids(repository, RiderRequestSort.mostUrgent), [
      'a', 'b',
      'c', ]);
    expect(await _ids(repository, RiderRequestSort.shortestTrip), [ 'a',
      'c', 'b',
    ]); expect(await _ids(repository, RiderRequestSort.earliestPickup), [
      'a', 'c',
      'b', ]);
    expect(await _ids(repository, RiderRequestSort.earliestDelivery), [ 'a',
      'c', 'b',
    ]); expect(await _ids(repository, RiderRequestSort.recentlyAvailable), [
      'a', 'c',
      'b', ]);
  }); test(
    'filters pickup and delivery windows, category, and fee range', () async {
      final page = await repository.fetchNearbyRequests( _query(
          filters: const RiderRequestFilters( pickupWithinMinutes: 40,
            deliveryWithinMinutes: 100, category: 'Produce',
            minimumFee: 100, maximumFee: 200,
          ), ),
      ); expect(page.items.map((item) => item.id), ['a']);
    }, );
  test('combines urgent, perishable, distance, and fee filters', () async { final page = await repository.fetchNearbyRequests(
      _query( filters: const RiderRequestFilters(
          urgentOnly: true, perishableOnly: true,
          maximumPickupDistanceKm: 5, minimumFee: 100,
        ), ),
    ); expect(page.items.map((item) => item.id), ['a']);
  }); test('hiding affects only the current Rider', () async {
    await repository.decline(requestId: 'a', riderId: 'rider-a'); final hidden = await repository.fetchNearbyRequests(_query());
    final other = await repository.fetchNearbyRequests( _query(riderId: 'rider-b'),
    ); expect(hidden.items.map((item) => item.id), isNot(contains('a')));
    expect(other.items.map((item) => item.id), contains('a')); });
} Future<List<String>> _ids(
  InMemoryRiderDeliveryRepository repository, RiderRequestSort sort,
) async => (await repository.fetchNearbyRequests( _query(sort: sort),
)).items.map((item) => item.id).toList(); RiderRequestQuery _query({
  String riderId = 'rider-a', String searchText = '',
  RiderRequestSort sort = RiderRequestSort.recommended, RiderRequestFilters filters = const RiderRequestFilters(),
  String? cursor, int pageSize = 10,
}) => RiderRequestQuery( matching: RiderMatchingContext(
    riderId: riderId, availability: RiderAvailability.onlineAvailable,
    vehicleType: RiderVehicleType.motorcycle, capacityKg: 150,
    serviceArea: 'Cagayan de Oro', serviceRadiusKm: 15,
    registeredLatitude: 8.48, registeredLongitude: 124.65,
    location: const RiderDeliverySearch(latitude: 8.48, longitude: 124.65), gpsAccuracyMeters: 5,
    activeDeliveryCount: 0, ),
  searchText: searchText, sort: sort,
  filters: filters, cursor: cursor,
  pageSize: pageSize, );
DeliveryRequest _request( DateTime now,
  String id, String product,
  double distance, double fee,
  DeliveryPriority priority, ) => DeliveryRequest(
  id: id, orderNumber: 'AGR-$id',
  productName: product, productCategory: 'Produce',
  sellerName: 'Carmen Farm $id', buyerName: 'Private buyer',
  pickupLocation: DeliveryLocation(address: id == 'a' ? 'Carmen' : 'Lumbia'), deliveryLocation: const DeliveryLocation(address: 'Uptown'),
  pickupDeadline: now.add( Duration(
      minutes: id == 'a' ? 30
          : id == 'c' ? 45
          : 60, ),
  ), deliveryDeadline: now.add(
    Duration( minutes: id == 'a'
          ? 90 : id == 'c'
          ? 120 : 180,
    ), ),
  availableAt: now.subtract( Duration(
      minutes: id == 'a' ? 1
          : id == 'c' ? 2
          : 3, ),
  ), expiresAt: now.add(const Duration(minutes: 50)),
  serviceArea: 'Cagayan de Oro', totalWeightKg: 20,
  distanceKm: distance, estimatedTravelMinutes: (distance * 3).round(),
  pickupToDeliveryDistanceKm: distance, pickupToDeliveryMinutes: (distance * 4).round(),
  deliveryFee: fee, priority: priority,
  requiredVehicleTypes: const {RiderVehicleType.motorcycle}, handlingRequirements: const [
    ProductHandlingRequirement(type: ProductHandlingType.perishable), ],
);
