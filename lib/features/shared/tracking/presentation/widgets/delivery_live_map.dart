import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/tracking/domain/delivery_tracking_models.dart';

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
      _mapController.move(widget.snapshot.riderLatLng!, _mapController.camera.zoom);
    }
  }

  void _fitRoute() {
    final points = <LatLng>[];
    if (widget.snapshot.riderLatLng != null) {
      points.add(widget.snapshot.riderLatLng!);
    }
    if (widget.snapshot.pickup != null) {
      points.add(widget.snapshot.pickup!.latLng);
    }
    if (widget.snapshot.destination != null) {
      points.add(widget.snapshot.destination!.latLng);
    }
    if (points.isEmpty && widget.snapshot.routeCoordinates.isNotEmpty) {
      points.addAll(widget.snapshot.routeCoordinates);
    }

    if (points.length >= 2) {
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(48),
        ),
      );
    } else if (points.length == 1) {
      _mapController.move(points.first, 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = widget.snapshot;
    final centerPoint = snapshot.riderLatLng ??
        snapshot.destination?.latLng ??
        snapshot.pickup?.latLng ??
        const LatLng(8.48, 124.65);

    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: centerPoint,
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
                        color: AgrisellColors.authGreen.withValues(alpha: 0.85),
                        strokeWidth: 5.0,
                      ),
                    ],
                  ),
                MarkerLayer(markers: _buildMarkers(snapshot)),
              ],
            ),

            // Top Stale GPS Warning Banner
            if (snapshot.gpsState == DeliveryGpsState.stale)
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFEEBA)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFF856404)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Stale GPS: Rider location was last updated >2 minutes ago.',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF856404),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Map Controls (Right Top)
            if (widget.showControls)
              Positioned(
                top: snapshot.gpsState == DeliveryGpsState.stale ? 54 : 10,
                right: 10,
                child: Column(
                  children: [
                    _MapActionButton(
                      icon: Icons.route_rounded,
                      tooltip: 'Center Route',
                      onPressed: _fitRoute,
                    ),
                    const SizedBox(height: 8),
                    if (widget.onToggleFollowRider != null && snapshot.hasRiderCoordinates)
                      _MapActionButton(
                        icon: widget.followRider
                            ? Icons.my_location_rounded
                            : Icons.location_searching_rounded,
                        tooltip: widget.followRider ? 'Following Rider' : 'Follow Rider',
                        isActive: widget.followRider,
                        onPressed: () => widget.onToggleFollowRider!(!widget.followRider),
                      ),
                    const SizedBox(height: 8),
                    if (widget.onRefresh != null)
                      _MapActionButton(
                        icon: Icons.refresh_rounded,
                        tooltip: 'Refresh Location',
                        isLoading: widget.isRefreshing,
                        onPressed: widget.onRefresh!,
                      ),
                  ],
                ),
              ),

            // Bottom Metrics and ETA Overlay
            if (widget.showDetailsOverlay)
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _StatusIndicatorDot(gpsState: snapshot.gpsState),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              snapshot.gpsState.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: snapshot.gpsState.isLive
                                    ? AgrisellColors.authGreen
                                    : (snapshot.gpsState.isStale
                                        ? const Color(0xFFD97706)
                                        : AgrisellColors.mutedText),
                              ),
                            ),
                          ),
                          if (snapshot.speedKph > 0.5) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AgrisellColors.forestSoft,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.speed_rounded, size: 14, color: AgrisellColors.authGreen),
                                  const SizedBox(width: 4),
                                  Text(
                                    snapshot.speedText,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AgrisellColors.authGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.schedule_rounded, size: 16, color: AgrisellColors.brandBlack),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              snapshot.arrivalWindowText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AgrisellColors.brandBlack,
                              ),
                            ),
                          ),
                          if (snapshot.distanceText.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              snapshot.distanceText,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AgrisellColors.mutedText,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Marker> _buildMarkers(DeliveryTrackingSnapshot snapshot) {
    final markers = <Marker>[];

    // 1. Pickup Marker (P)
    if (snapshot.pickup != null) {
      markers.add(
        Marker(
          point: snapshot.pickup!.latLng,
          width: 44,
          height: 44,
          child: Tooltip(
            message: 'Pickup: ${snapshot.pickup!.name}',
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'P',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // 2. Destination Marker (D)
    if (snapshot.destination != null) {
      markers.add(
        Marker(
          point: snapshot.destination!.latLng,
          width: 44,
          height: 44,
          child: Tooltip(
            message: 'Destination: ${snapshot.destination!.name}',
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'D',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // 3. Rider Marker (R)
    if (snapshot.hasRiderCoordinates) {
      final isLive = snapshot.gpsState.isLive;
      final color = isLive ? AgrisellColors.authGreen : Colors.grey.shade600;

      markers.add(
        Marker(
          point: snapshot.riderLatLng!,
          width: 52,
          height: 52,
          child: Tooltip(
            message: 'Rider: ${snapshot.riderName ?? 'Courier'} (${snapshot.speedText})',
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isLive)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AgrisellColors.authGreen.withValues(alpha: 0.2),
                    ),
                  ),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
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
          ),
        ),
      );
    }

    return markers;
  }
}

class _MapActionButton extends StatelessWidget {
  const _MapActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isActive = false,
    this.isLoading = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isActive;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? AgrisellColors.authGreen : Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 3,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AgrisellColors.authGreen,
                    ),
                  )
                : Icon(
                    icon,
                    size: 20,
                    color: isActive ? Colors.white : AgrisellColors.brandBlack,
                  ),
          ),
        ),
      ),
    );
  }
}

class _StatusIndicatorDot extends StatelessWidget {
  const _StatusIndicatorDot({required this.gpsState});

  final DeliveryGpsState gpsState;

  @override
  Widget build(BuildContext context) {
    final color = switch (gpsState) {
      DeliveryGpsState.recent => AgrisellColors.authGreen,
      DeliveryGpsState.stale => const Color(0xFFD97706),
      DeliveryGpsState.noLocation || DeliveryGpsState.unassigned => Colors.grey.shade500,
    };

    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          if (gpsState.isLive)
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 4,
              spreadRadius: 1,
            ),
        ],
      ),
    );
  }
}
