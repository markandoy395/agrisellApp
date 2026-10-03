import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:agresell_app/features/shared/tracking/domain/delivery_tracking_models.dart';

import '../styles/delivery_live_map_styles.dart';
import '../utils/delivery_map_geometry.dart';
import 'delivery_map_controls.dart';
import 'delivery_map_markers.dart';
import 'delivery_map_overlays.dart';

class DeliveryLiveMap extends StatefulWidget {
  const DeliveryLiveMap({
    required this.snapshot,
    this.height = 360,
    this.followRider = false,
    this.onToggleFollowRider,
    this.onRefresh,
    this.isRefreshing = false,
    this.showControls = true,
    this.showDetailsOverlay = true,
    super.key,
  });

  final DeliveryTrackingSnapshot snapshot;
  final double height;
  final bool followRider;
  final ValueChanged<bool>? onToggleFollowRider;
  final VoidCallback? onRefresh;
  final bool isRefreshing;
  final bool showControls;
  final bool showDetailsOverlay;

  @override
  State<DeliveryLiveMap> createState() => _DeliveryLiveMapState();
}

class _DeliveryLiveMapState extends State<DeliveryLiveMap> {
  late final MapController _mapController;
  bool _fitted = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void didUpdateWidget(covariant DeliveryLiveMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.followRider && widget.snapshot.riderLatLng != null) {
      _mapController.move(
        widget.snapshot.riderLatLng!,
        _mapController.camera.zoom,
      );
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _fitRoute() {
    final points = deliveryMapFitPoints(widget.snapshot);
    if (points.length >= 2) {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: DeliveryLiveMapStyles.cameraPadding,
        ),
      );
    } else if (points.length == 1) {
      _mapController.move(points.first, 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = widget.snapshot;
    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: DeliveryLiveMapStyles.mapRadius,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: deliveryMapCenter(snapshot),
                initialZoom: 14.5,
                minZoom: 4,
                maxZoom: 19,
                onMapReady: () {
                  if (!_fitted) {
                    _fitRoute();
                    _fitted = true;
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.agrisell.agresell_app',
                ),
                if (snapshot.hasRoute)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: snapshot.routeCoordinates,
                        color: DeliveryLiveMapStyles.routeColor,
                        strokeWidth: 5.0,
                      ),
                    ],
                  ),
                MarkerLayer(markers: buildDeliveryMapMarkers(snapshot)),
              ],
            ),
            if (snapshot.gpsState.isStale)
              const Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: DeliveryStaleGpsWarning(),
              ),
            if (widget.showControls)
              Positioned(
                top: snapshot.gpsState.isStale ? 54 : 10,
                right: 10,
                child: DeliveryMapControls(
                  onFitRoute: _fitRoute,
                  hasRiderCoordinates: snapshot.hasRiderCoordinates,
                  followRider: widget.followRider,
                  isRefreshing: widget.isRefreshing,
                  onToggleFollowRider: widget.onToggleFollowRider,
                  onRefresh: widget.onRefresh,
                ),
              ),
            if (widget.showDetailsOverlay)
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: DeliveryMapDetailsOverlay(snapshot: snapshot),
              ),
          ],
        ),
      ),
    );
  }
}
