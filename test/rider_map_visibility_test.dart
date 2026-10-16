import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_map_visibility.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_marker_builder.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_icon_marker.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_types.dart';
import 'package:agresell_app/features/shared/routing/domain/delivery_route.dart';

void main() {
  test(
    'drop-off toggle is independent and never exposes another rider delivery',
    () {
      final map = MapController();
      addTearDown(map.dispose);
      List<String> labels(RiderMapVisibility visibility) =>
          RiderMapMarkerBuilder(
                riderPoint: const DeliveryRoutePoint(
                  latitude: 8.48,
                  longitude: 124.65,
                ),
                requests: [
                  _request('owned', 'rider-a'),
                  _request('foreign', 'rider-b'),
                ],
                farms: const [],
                riderId: 'rider-a',
                filter: RiderMapFilter.all,
                mapZoom: 15,
                discoveryRadiusKm: 15,
                mapController: map,
                visibility: visibility,
                onMarkerTap: (_, _) {},
                onFarmTap: (_) {},
              )
              .buildMarkers(const LatLng(8.48, 124.65))
              .map((marker) => (marker.child as RiderMapIconMarker).label)
              .toList();

      expect(
        labels(const RiderMapVisibility()),
        containsAll([
          'Assigned pickup: owned seller',
          'Assigned drop-off: owned',
          'Your current location',
        ]),
      );
      expect(
        labels(const RiderMapVisibility()).join(' '),
        isNot(contains('foreign')),
      );
      expect(
        labels(const RiderMapVisibility(dropOffs: false)),
        isNot(contains('Assigned drop-off: owned')),
      );
      expect(
        labels(const RiderMapVisibility(active: false)),
        contains('Assigned drop-off: owned'),
      );
      expect(labels(const RiderMapVisibility(active: false, dropOffs: false)), [
        'Your current location',
      ]);
    },
  );
}

DeliveryRequest _request(String id, String riderId) => DeliveryRequest(
  id: id,
  orderNumber: id,
  productName: 'Produce',
  sellerName: '$id seller',
  buyerName: 'Buyer',
  pickupLocation: const DeliveryLocation(
    address: 'Farm',
    latitude: 8.49,
    longitude: 124.66,
  ),
  deliveryLocation: const DeliveryLocation(
    address: 'Buyer',
    latitude: 8.50,
    longitude: 124.67,
  ),
  pickupDeadline: DateTime(2030),
  stage: DeliveryStage.accepted,
  assignedRiderId: riderId,
);
