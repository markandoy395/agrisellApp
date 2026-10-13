import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

class LocationSelectorMap extends StatelessWidget {
  const LocationSelectorMap({
    required this.controller,
    required this.selected,
    required this.detected,
    required this.accuracyMeters,
    required this.centerPinMode,
    required this.onSelected,
    required this.onMapMoved,
    required this.onTileError,
    required this.onZoom,
    required this.onUseCurrentLocation,
    required this.locating,
    required this.mapKey,
    super.key,
  });

  final MapController controller;
  final LatLng selected;
  final LatLng? detected;
  final double? accuracyMeters;
  final bool centerPinMode;
  final ValueChanged<LatLng> onSelected;
  final ValueChanged<LatLng> onMapMoved;
  final VoidCallback onTileError;
  final ValueChanged<double> onZoom;
  final VoidCallback onUseCurrentLocation;
  final bool locating;
  final GlobalKey mapKey;

  @override
  Widget build(BuildContext context) => Stack(
    key: mapKey,
    children: [
      FlutterMap(
        mapController: controller,
        options: MapOptions(
          initialCenter: selected,
          initialZoom: 16,
          onTap: centerPinMode ? null : (_, point) => onSelected(point),
          onPositionChanged: (camera, hasGesture) {
            if (centerPinMode && hasGesture) onMapMoved(camera.center);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.agrisell.agresell_app',
            errorTileCallback: (_, _, _) => onTileError(),
          ),
          if (detected != null && accuracyMeters != null)
            CircleLayer(
              circles: [
                CircleMarker(
                  point: detected!,
                  radius: accuracyMeters!,
                  useRadiusInMeter: true,
                  color: AgrisellColors.statusBlueText.withValues(alpha: .13),
                  borderColor: AgrisellColors.statusBlueText,
                  borderStrokeWidth: 1.5,
                ),
              ],
            ),
          if (!centerPinMode)
            MarkerLayer(
              markers: [
                Marker(
                  point: selected,
                  width: 48,
                  height: 48,
                  alignment: Alignment.topCenter,
                  rotate: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: (details) => _dragPin(details.delta),
                    child: Semantics(
                      label: 'Draggable selected location pin',
                      child: const Icon(
                        Icons.location_pin,
                        color: AgrisellColors.statusRedText,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          const RichAttributionWidget(
            attributions: [TextSourceAttribution('OpenStreetMap contributors')],
          ),
        ],
      ),
      if (centerPinMode)
        const IgnorePointer(
          child: Center(
            child: SizedBox(
              height: 96,
              child: Align(
                alignment: Alignment.topCenter,
                child: Icon(
                  Icons.location_pin,
                  color: AgrisellColors.statusRedText,
                  size: 48,
                ),
              ),
            ),
          ),
        ),
      Positioned(
        right: 12,
        bottom: 38,
        child: _LocationMapControls(
          onZoom: onZoom,
          onUseCurrentLocation: onUseCurrentLocation,
          locating: locating,
        ),
      ),
    ],
  );

  void _dragPin(Offset delta) {
    final camera = controller.camera;
    onSelected(
      camera.screenOffsetToLatLng(
        camera.latLngToScreenOffset(selected) + delta,
      ),
    );
  }
}

class _LocationMapControls extends StatelessWidget {
  const _LocationMapControls({
    required this.onZoom,
    required this.onUseCurrentLocation,
    required this.locating,
  });

  final ValueChanged<double> onZoom;
  final VoidCallback onUseCurrentLocation;
  final bool locating;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      FloatingActionButton.small(
        heroTag: null,
        tooltip: 'Zoom in',
        onPressed: () => onZoom(1),
        child: const Icon(Icons.add),
      ),
      const SizedBox(height: 8),
      FloatingActionButton.small(
        heroTag: null,
        tooltip: 'Zoom out',
        onPressed: () => onZoom(-1),
        child: const Icon(Icons.remove),
      ),
      const SizedBox(height: 8),
      FloatingActionButton.small(
        heroTag: null,
        tooltip: 'Use my current location',
        onPressed: locating ? null : onUseCurrentLocation,
        child: locating
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.my_location),
      ),
    ],
  );
}
