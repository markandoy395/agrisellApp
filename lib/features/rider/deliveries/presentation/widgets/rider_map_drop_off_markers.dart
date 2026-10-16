import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/delivery_request.dart';
import '../../domain/delivery_stage.dart';
import 'rider_map_icon_marker.dart';

List<Marker> riderMapDropOffMarkers(
  List<DeliveryRequest> assigned, {
  required bool activeVisible,
}) => [
  for (final request in assigned)
    if (request.deliveryLocation.hasCoordinates &&
        (!request.stage.isDeliveryLeg || !activeVisible))
      Marker(
        point: LatLng(
          request.deliveryLocation.latitude!,
          request.deliveryLocation.longitude!,
        ),
        width: 60,
        height: 60,
        child: RiderMapIconMarker(
          icon: Icons.location_on,
          label: 'Assigned drop-off: ${request.orderNumber}',
        ),
      ),
];
