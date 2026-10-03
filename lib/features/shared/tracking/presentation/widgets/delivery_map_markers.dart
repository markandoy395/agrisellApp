import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:agresell_app/features/shared/tracking/domain/delivery_tracking_models.dart';

import '../styles/delivery_live_map_styles.dart';

List<Marker> buildDeliveryMapMarkers(DeliveryTrackingSnapshot snapshot) => [
  if (snapshot.pickup != null)
    Marker(
      point: snapshot.pickup!.latLng,
      width: 44,
      height: 44,
      child: _StopMarker(
        label: 'P',
        tooltip: 'Pickup: ${snapshot.pickup!.name}',
        decoration: DeliveryLiveMapStyles.pickupDecoration,
      ),
    ),
  if (snapshot.destination != null)
    Marker(
      point: snapshot.destination!.latLng,
      width: 44,
      height: 44,
      child: _StopMarker(
        label: 'D',
        tooltip: 'Destination: ${snapshot.destination!.name}',
        decoration: DeliveryLiveMapStyles.destinationDecoration,
      ),
    ),
  if (snapshot.hasRiderCoordinates)
    Marker(
      point: snapshot.riderLatLng!,
      width: 52,
      height: 52,
      child: _RiderMarker(snapshot: snapshot),
    ),
];

class _StopMarker extends StatelessWidget {
  const _StopMarker({
    required this.label,
    required this.tooltip,
    required this.decoration,
  });
  final String label;
  final String tooltip;
  final BoxDecoration decoration;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Container(
      decoration: decoration,
      child: Center(child: Text(label, style: DeliveryLiveMapStyles.stopText)),
    ),
  );
}

class _RiderMarker extends StatelessWidget {
  const _RiderMarker({required this.snapshot});
  final DeliveryTrackingSnapshot snapshot;

  @override
  Widget build(BuildContext context) => Tooltip(
    message:
        'Rider: ${snapshot.riderName ?? 'Courier'} (${snapshot.speedText})',
    child: Stack(
      alignment: Alignment.center,
      children: [
        if (snapshot.gpsState.isLive)
          Container(
            width: 50,
            height: 50,
            decoration: DeliveryLiveMapStyles.riderHalo,
          ),
        Container(
          width: 38,
          height: 38,
          decoration: DeliveryLiveMapStyles.riderDecoration(
            snapshot.gpsState.isLive,
          ),
          child: Transform.rotate(
            angle: (snapshot.riderHeading * math.pi) / 180,
            child: const Icon(
              Icons.navigation_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    ),
  );
}
