import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/farmer/reservations/data/farmer_rider_selection_mapper.dart';
import 'package:agresell_app/features/farmer/reservations/data/farmer_rider_selection_repository.dart';
import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_candidate.dart';
import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_request.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/screens/farmer_rider_selection_screen.dart';
import 'package:agresell_app/features/shared/orders/domain/rider_assignment_request_status.dart';

void main() {
  test(
    'mapper excludes unavailable riders and sorts eligible riders by distance',
    () {
      const mapper = FarmerRiderSelectionMapper();
      final value = mapper.selection({
        'order': {
          'seller_order_id': 'ORDER-F1',
          'delivery_id': 8,
          'pickup_address': 'Poblacion farm',
          'pickup_barangay': 'Poblacion',
          'pickup_municipality': 'Lianga',
          'destination': 'Buyer address',
          'goods_summary': '2 kg Tomatoes',
          'requested_schedule': '2026-08-02T10:00:00Z',
        },
        'riders': [
          _riderRow('same-far', 'Same Far', sameBarangay: true, distance: 4),
          _riderRow('near', 'Near Rider', sameBarangay: false, distance: 1),
          _riderRow(
            'offline-near',
            'Offline Near',
            sameBarangay: true,
            distance: .5,
            availability: 'offline',
            isRequestable: false,
          ),
        ],
      });

      expect(
        value.riders.map((rider) => rider.id),
        orderedEquals(['near', 'same-far']),
      );
    },
  );

  test(
    'mapper uses municipality relationship only after distance and workload',
    () {
      const mapper = FarmerRiderSelectionMapper();
      final value = mapper.selection({
        'order': {
          'seller_order_id': 'ORDER-F1',
          'delivery_id': 8,
          'pickup_address': 'Poblacion farm',
          'pickup_barangay': 'Poblacion',
          'pickup_municipality': 'Esperanza',
          'destination': 'Buyer address',
          'requested_schedule': '2026-08-02T10:00:00Z',
        },
        'riders': [
          _riderRow(
            'province',
            'Province Rider',
            sameBarangay: true,
            sameMunicipality: false,
            distance: 1,
          ),
          _riderRow(
            'municipal',
            'Municipal Rider',
            sameBarangay: false,
            sameMunicipality: true,
            distance: 5,
          ),
        ],
      });

      expect(value.riders.first.id, 'province');
    },
  );

  test('mapper marks an offline rider unavailable to select', () {
    const mapper = FarmerRiderSelectionMapper();
    final rider = mapper.candidate({
      ..._riderRow('offline', 'Offline Rider', sameBarangay: false),
      'availability_status': 'offline',
      'is_requestable': false,
    });

    expect(rider.availabilityStatus, 'offline');
    expect(rider.isAvailable, isFalse);
    expect(rider.canReceiveRequest, isFalse);
  });

  test('mapper keeps a manually requestable offline rider', () {
    const mapper = FarmerRiderSelectionMapper();
    final value = mapper.selection({
      'order': {
        'seller_order_id': 'ORDER-F1',
        'delivery_id': 8,
        'pickup_address': 'Poblacion farm',
        'pickup_barangay': 'Poblacion',
        'pickup_municipality': 'Lianga',
        'destination': 'Buyer address',
        'requested_schedule': '2026-08-02T10:00:00Z',
      },
      'riders': [
        _riderRow(
          'offline-manual',
          'Offline Manual',
          sameBarangay: true,
          availability: 'offline',
          distance: 3,
        ),
      ],
    });

    expect(value.riders.single.id, 'offline-manual');
    expect(value.riders.single.isOfflineManualCandidate, isTrue);
    expect(value.riders.single.canReceiveRequest, isTrue);
    expect(value.riders.single.isAvailable, isFalse);
  });

  test('mapper reads buyer destination route fields', () {
    const mapper = FarmerRiderSelectionMapper();
    final value = mapper.selection({
      'order': {
        'seller_order_id': 'ORDER-F1',
        'delivery_id': 8,
        'pickup_address': 'Poblacion farm',
        'pickup_barangay': 'Poblacion',
        'pickup_municipality': 'Lianga',
        'destination': 'San Agustin buyer',
        'destination_latitude': 8.61,
        'destination_longitude': 126.09,
        'route_distance_km': 12.4,
        'estimated_delivery_minutes': 50,
        'requested_schedule': '2026-08-02T10:00:00Z',
      },
      'riders': [
        {
          ..._riderRow('supported', 'Supported Rider', sameBarangay: true),
          'destination_supported': true,
          'delivery_distance_km': 12.4,
        },
        {
          ..._riderRow('unsupported', 'Unsupported Rider', sameBarangay: true),
          'destination_supported': false,
        },
      ],
    });

    expect(value.delivery.destination, 'San Agustin buyer');
    expect(value.delivery.destinationLatitude, 8.61);
    expect(value.delivery.routeDistanceKm, 12.4);
    expect(value.delivery.estimatedDeliveryMinutes, 50);
    expect(value.riders.first.id, 'supported');
    expect(value.riders.first.deliveryDistanceKm, 12.4);
    expect(value.riders, hasLength(1));
  });

  test(
    'keeps all 15 eligible riders and excludes the 15 unavailable riders',
    () {
      const mapper = FarmerRiderSelectionMapper();
      final riders = List<Map<String, Object?>>.generate(30, (index) {
        final requestable = index.isEven;
        return _riderRow(
          'rider-$index',
          'Rider $index',
          sameBarangay: true,
          sameMunicipality: true,
          distance: 30 - index.toDouble(),
          availability: requestable ? 'online' : 'offline',
          isRequestable: requestable,
        );
      });
      final value = mapper.selection({
        'order': {
          'seller_order_id': 'ORDER-F1',
          'delivery_id': 8,
          'pickup_address': 'Poblacion farm',
          'pickup_barangay': 'Poblacion',
          'pickup_municipality': 'Lianga',
          'destination': 'Buyer address',
          'requested_schedule': '2026-08-02T10:00:00Z',
        },
        'riders': riders,
      });

      expect(value.riders, hasLength(15));
      expect(value.riders.every((rider) => rider.canReceiveRequest), isTrue);
      expect(value.riders.first.id, 'rider-28');
      expect(value.riders.first.distanceKm, 2);
    },
  );

  test('does not apply a distance cutoff to eligible riders', () {
    const mapper = FarmerRiderSelectionMapper();
    final value = mapper.selection({
      'order': {
        'seller_order_id': 'ORDER-F1',
        'delivery_id': 8,
        'pickup_address': 'Poblacion farm',
        'pickup_barangay': 'Poblacion',
        'pickup_municipality': 'Lianga',
        'destination': 'Buyer address',
        'requested_schedule': '2026-08-02T10:00:00Z',
      },
      'riders': [
        _riderRow('far', 'Far Rider', sameBarangay: false, distance: 42),
        _riderRow('near', 'Near Rider', sameBarangay: true, distance: 2),
        _riderRow(
          'offline',
          'Offline Rider',
          sameBarangay: true,
          distance: 1,
          availability: 'offline',
          isRequestable: false,
        ),
      ],
    });

    expect(
      value.riders.map((rider) => rider.id),
      orderedEquals(['near', 'far']),
    );
    expect(value.riders.last.distanceKm, 42);
  });

  testWidgets('shows barangay grouping and confirms before requesting', (
    tester,
  ) async {
    final repository = _FakeRepository(_selection(_candidates));
    await tester.pumpWidget(
      MaterialApp(
        home: FarmerRiderSelectionScreen(
          orderId: 'ORDER-F1',
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'All eligible riders are shown nearest to farthest from '
        'the pickup location. The rider must still accept before '
        'assignment.',
      ),
      findsOneWidget,
    );
    expect(_richText('Pickup: Poblacion farm'), findsOneWidget);
    expect(_richText('Delivery: Buyer address'), findsOneWidget);
    expect(find.text('Within 15 km service area'), findsWidgets);
    expect(find.text('Ana Rider'), findsWidgets);
    expect(find.text('Ben Rider'), findsWidgets);

    await tester.tap(find.text('Select rider').first);
    await tester.pumpAndSettle();
    expect(find.text('Confirm rider request'), findsOneWidget);
    expect(
      find.text('The rider must accept before this order is assigned.'),
      findsOneWidget,
    );
    expect(repository.requestedRider, isNull);

    await tester.tap(find.text('Send request'));
    await tester.pumpAndSettle();
    expect(repository.requestedRider?.name, 'Ana Rider');
  });

  testWidgets('screen shows every eligible Rider nearest first', (
    tester,
  ) async {
    final repository = _FakeRepository(
      _selection(const [
        FarmerRiderCandidate(
          id: 'far',
          name: 'Far Eligible',
          barangay: 'Baugo',
          municipality: 'Lianga',
          sameBarangay: false,
          distanceKm: 9.4,
          rating: 4.9,
          completedDeliveries: 30,
        ),
        FarmerRiderCandidate(
          id: 'offline',
          name: 'Offline Nearby',
          barangay: 'Poblacion',
          municipality: 'Lianga',
          sameBarangay: true,
          availabilityStatus: 'offline',
          isRequestable: false,
          distanceKm: 0.5,
          rating: 5,
          completedDeliveries: 50,
        ),
        FarmerRiderCandidate(
          id: 'near',
          name: 'Near Eligible',
          barangay: 'Poblacion',
          municipality: 'Lianga',
          sameBarangay: true,
          distanceKm: 1.8,
          rating: 4.5,
          completedDeliveries: 12,
        ),
      ]),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: FarmerRiderSelectionScreen(
          orderId: 'ORDER-F1',
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Near Eligible'), findsOneWidget);
    expect(find.text('Far Eligible'), findsOneWidget);
    expect(find.text('Offline Nearby'), findsNothing);
    expect(find.text('1.8 km from pickup'), findsOneWidget);
    expect(find.text('9.4 km from pickup'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Near Eligible')).dy,
      lessThan(tester.getTopLeft(find.text('Far Eligible')).dy),
    );
  });

  testWidgets('farmer can confirm a 45-minute offline Rider booking', (
    tester,
  ) async {
    final repository = _FakeRepository(
      _selection(const [
        FarmerRiderCandidate(
          id: 'offline-manual',
          name: 'Offline Manual',
          barangay: 'Poblacion',
          municipality: 'Lianga',
          sameBarangay: true,
          availabilityStatus: 'offline',
          distanceKm: 2.5,
          rating: 4.7,
          completedDeliveries: 20,
        ),
      ]),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: FarmerRiderSelectionScreen(
          orderId: 'ORDER-F1',
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Offline Manual'), findsOneWidget);
    expect(find.text('2.5 km from pickup'), findsOneWidget);
    expect(find.text('Book offline rider'), findsOneWidget);
    await tester.tap(find.text('Book offline rider'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'This rider is offline. The booking expires in 45 minutes unless the rider accepts.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows municipality empty state and refresh action', (
    tester,
  ) async {
    final repository = _FakeRepository(_selection(const []));
    await tester.pumpWidget(
      MaterialApp(
        home: FarmerRiderSelectionScreen(
          orderId: 'ORDER-F1',
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No eligible riders available'), findsOneWidget);
    expect(find.text('Refresh'), findsOneWidget);
  });
}

Finder _richText(String text) => find.byWidgetPredicate(
  (widget) => widget is RichText && widget.text.toPlainText() == text,
);

Map<String, Object?> _riderRow(
  String id,
  String name, {
  required bool sameBarangay,
  bool sameMunicipality = true,
  double? distance,
  double rating = 4,
  String availability = 'online',
  bool isRequestable = true,
}) => {
  'rider_id': id,
  'name': name,
  'barangay': sameBarangay ? 'Poblacion' : 'Baugo',
  'municipality': 'Lianga',
  'same_barangay': sameBarangay,
  'same_municipality': sameMunicipality,
  'distance_km': distance,
  'location_is_fresh': distance != null,
  'is_requestable': isRequestable,
  'rating': rating,
  'completed_deliveries': 10,
  'availability_status': availability,
};

const _candidates = [
  FarmerRiderCandidate(
    id: 'ana',
    name: 'Ana Rider',
    barangay: 'Poblacion',
    municipality: 'Lianga',
    sameBarangay: true,
    distanceKm: 1.2,
    rating: 4.8,
    completedDeliveries: 42,
    proposedDeliveryFee: 85,
  ),
  FarmerRiderCandidate(
    id: 'ben',
    name: 'Ben Rider',
    barangay: 'Baugo',
    municipality: 'Lianga',
    sameBarangay: false,
    rating: 4.9,
    completedDeliveries: 60,
  ),
];

FarmerRiderSelectionData _selection(List<FarmerRiderCandidate> riders) =>
    FarmerRiderSelectionData(
      delivery: FarmerRiderDeliveryDetails(
        orderId: 'ORDER-F1',
        deliveryId: '8',
        pickupAddress: 'Poblacion farm',
        pickupBarangay: 'Poblacion',
        pickupMunicipality: 'Lianga',
        destination: 'Buyer address',
        goodsSummary: '2 kg Tomatoes',
        requestedSchedule: DateTime(2026, 8, 2, 18),
        proposedDeliveryFee: 85,
      ),
      riders: riders,
    );

class _FakeRepository implements FarmerRiderSelectionRepository {
  _FakeRepository(this.selection);

  final FarmerRiderSelectionData selection;
  FarmerRiderCandidate? requestedRider;

  @override
  Future<FarmerRiderSelectionData> loadEligibleRiders(String orderId) async =>
      selection;

  @override
  Future<List<FarmerRiderRequest>> loadCurrentRequests() async => const [];

  @override
  Stream<List<FarmerRiderRequest>> watchCurrentRequests() =>
      Stream.value(const []);

  @override
  Future<FarmerRiderRequest> requestRider({
    required FarmerRiderDeliveryDetails delivery,
    required FarmerRiderCandidate rider,
  }) async {
    requestedRider = rider;
    return FarmerRiderRequest(
      id: 'request-1',
      deliveryId: delivery.deliveryId,
      orderId: delivery.orderId,
      riderId: rider.id,
      riderName: rider.name,
      status: RiderAssignmentRequestStatus.pending,
      requestedSchedule: delivery.requestedSchedule,
      requestedAt: DateTime(2026, 8, 2, 10),
      expiresAt: DateTime(2026, 8, 2, 10, 15),
    );
  }

  @override
  Future<FarmerRiderRequest> cancelRequest(String requestId) =>
      throw UnimplementedError();
}
