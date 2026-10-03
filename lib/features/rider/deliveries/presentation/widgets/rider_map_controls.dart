import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:agresell_app/features/rider/deliveries/presentation/rider_map_camera_policy.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_map_styles.dart';

/// Floating zoom and recenter controls for the rider map.
class RiderMapControls extends StatelessWidget {
  const RiderMapControls({
    required this.mapController,
    required this.onRecenter,
    super.key,
  });

  final MapController mapController;
  final VoidCallback onRecenter;

  void _zoomIn() {
    final camera = mapController.camera;
    if (!RiderMapCameraPolicy.canMoveCamera(camera)) return;
    mapController.move(
      camera.center,
      RiderMapCameraPolicy.safeZoom(camera.zoom + 1),
    );
  }

  void _zoomOut() {
    final camera = mapController.camera;
    if (!RiderMapCameraPolicy.canMoveCamera(camera)) return;
    mapController.move(
      camera.center,
      RiderMapCameraPolicy.safeZoom(camera.zoom - 1),
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      FloatingActionButton.small(
        heroTag: 'rider-map-zoom-in',
        tooltip: 'Zoom in',
        onPressed: _zoomIn,
        backgroundColor: RiderMapStyles.fabBackground,
        foregroundColor: RiderMapStyles.fabForeground,
        child: const Icon(Icons.add_rounded),
      ),
      const SizedBox(height: RiderMapStyles.overlaySpacing),
      FloatingActionButton.small(
        heroTag: 'rider-map-zoom-out',
        tooltip: 'Zoom out',
        onPressed: _zoomOut,
        backgroundColor: RiderMapStyles.fabBackground,
        foregroundColor: RiderMapStyles.fabForeground,
        child: const Icon(Icons.remove_rounded),
      ),
      const SizedBox(height: RiderMapStyles.overlaySpacing),
      FloatingActionButton.small(
        heroTag: 'rider-map-recenter',
        tooltip: 'Follow current location',
        onPressed: onRecenter,
        backgroundColor: RiderMapStyles.fabBackground,
        foregroundColor: RiderMapStyles.fabForeground,
        child: const Icon(Icons.my_location_rounded),
      ),
    ],
  );
}
