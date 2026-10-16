import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../../domain/delivery_request.dart';
import '../styles/rider_delivery_reference_styles.dart';
import '../styles/rider_live_map_styles.dart';
import 'rider_detail_card.dart';
import 'rider_detail_map_geometry.dart';

class RiderDetailRoutePreview extends StatelessWidget {
  const RiderDetailRoutePreview({
    required this.request,
    required this.onOpenMap,
    super.key,
  });
  final DeliveryRequest request;
  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context) {
    final pickup = riderDetailMapPoint(
      request.pickupLocation.latitude,
      request.pickupLocation.longitude,
    );
    final dropoff = riderDetailMapPoint(
      request.deliveryLocation.latitude,
      request.deliveryLocation.longitude,
    );
    final route = [
      for (final point in request.route?.points ?? [])
        if (riderDetailMapPoint(point.latitude, point.longitude)
            case final value?)
          value,
    ];
    final points = [
      if (pickup != null) pickup,
      if (dropoff != null) dropoff,
      ...route,
    ];
    return RiderDetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.route_outlined, color: AgrisellColors.authGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.totalTripDistanceKm == null
                          ? 'Delivery route'
                          : '${request.totalTripDistanceKm!.toStringAsFixed(1)} km',
                      style: RiderDeliveryReferenceStyles.title,
                    ),
                    if (request.totalTripMinutes case final minutes?)
                      Text(
                        'Estimated total · $minutes min',
                        style: RiderDeliveryReferenceStyles.caption,
                      ),
                  ],
                ),
              ),
              TextButton.icon(
                style: RiderDeliveryReferenceStyles.mapButton,
                onPressed: onOpenMap,
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text('Open in Maps'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (points.isEmpty)
            Text(
              'Saved route coordinates are unavailable.',
              style: RiderDeliveryReferenceStyles.caption,
            )
          else
            ClipRRect(
              borderRadius: RiderDeliveryReferenceStyles.radius,
              child: SizedBox(
                height: RiderDeliveryReferenceStyles.mapHeight,
                child: FlutterMap(
                  key: ValueKey(
                    'detail-map-${request.id}-$pickup-$dropoff-${route.length}',
                  ),
                  options: MapOptions(
                    initialCenter: points.first,
                    initialCameraFit:
                        points.length > 1 &&
                            points.any((p) => p != points.first)
                        ? CameraFit.bounds(
                            bounds: LatLngBounds.fromPoints(points),
                            padding: const EdgeInsets.all(35),
                            maxZoom: 15,
                          )
                        : null,
                    initialZoom: 14,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                    backgroundColor: AgrisellColors.forestSoft,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: RiderLiveMapStyles.osmTileUrl,
                      userAgentPackageName: RiderLiveMapStyles.osmUserAgent,
                    ),
                    if (route.length > 1)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: route,
                            color: RiderDeliveryReferenceStyles.mapStroke,
                            strokeWidth: 5,
                            borderColor: AgrisellColors.surface,
                            borderStrokeWidth: 2,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        if (pickup != null)
                          _marker(
                            pickup,
                            'Pickup',
                            AgrisellColors.authGreen,
                            Icons.inventory_2_outlined,
                          ),
                        if (dropoff != null)
                          _marker(
                            dropoff,
                            'Drop-off',
                            AgrisellColors.statusRedText,
                            Icons.location_on_rounded,
                          ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Material(
                        color: AgrisellColors.surface,
                        child: InkWell(
                          onTap: () => launchUrl(
                            Uri.parse(
                              'https://www.openstreetmap.org/copyright',
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: Text(
                              '\u00a9 OpenStreetMap contributors',
                              style: RiderDeliveryReferenceStyles.caption,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (points.isNotEmpty && route.length < 2)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Pickup and drop-off locations · Road route not available yet',
                style: RiderDeliveryReferenceStyles.caption,
              ),
            ),
        ],
      ),
    );
  }

  Marker _marker(LatLng point, String label, Color color, IconData icon) =>
      Marker(
        point: point,
        width: 38,
        height: 38,
        child: Semantics(
          label: label,
          child: Container(
            decoration: RiderDeliveryReferenceStyles.marker(color),
            child: Icon(icon, color: AgrisellColors.surface, size: 22),
          ),
        ),
      );
}
