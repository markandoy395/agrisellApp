import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'rider_map_icon_marker.dart';

abstract final class RiderMapPoiMarkers {
  static List<Marker> build({
    required LatLng center,
    required bool visible,
  }) {
    if (!visible) return const [];

    final pois = [
      (
        name: 'SM Cabanatuan',
        icon: Icons.storefront_rounded,
        offset: const LatLng(0.008, -0.012),
      ),
      (
        name: 'Rizal Park',
        icon: Icons.park_rounded,
        offset: const LatLng(-0.010, -0.004),
      ),
      (
        name: "Nueva Ecija Doctor's Hospital",
        icon: Icons.local_hospital_rounded,
        offset: const LatLng(-0.014, 0.008),
      ),
    ];

    return [
      for (final poi in pois)
        Marker(
          point: LatLng(
            center.latitude + poi.offset.latitude,
            center.longitude + poi.offset.longitude,
          ),
          width: 80,
          height: 64,
          child: RiderMapIconMarker(
            icon: poi.icon,
            label: poi.name,
            caption: poi.name,
            tapExtent: 64,
          ),
        ),
    ];
  }
}
